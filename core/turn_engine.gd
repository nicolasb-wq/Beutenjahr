class_name TurnEngine
extends RefCounted
## Steuert den Begegnungsablauf als reine Zustandsmaschine — exakt die
## Reihenfolge aus ADR-0003. Kein Node-Zugriff, deterministisch ueber die
## seeded RNG-Stroeme.
##
## Nutzung: start_encounter() -> (play_card()* -> end_turn())* bis is_over().

var enc: EncounterState
var rng: RngService
var content: ContentDB
var game_log: GameLog
var relics: Array = []  # Relikt-Definitionen (Dictionaries)
var interp: EffectInterpreter

var _fired_threshold: Dictionary = {}  # Relikt-id -> bereits gefeuert


func _init(
	encounter: EncounterState,
	rng_service: RngService,
	content_db: ContentDB,
	log_sink: GameLog,
	relic_defs: Array = []
) -> void:
	enc = encounter
	rng = rng_service
	content = content_db
	game_log = log_sink
	relics = relic_defs
	interp = EffectInterpreter.new(enc, rng, game_log)


func start_encounter() -> void:
	var tname := enc.threat.id if enc.threat != null else "?"
	game_log.add("=== Begegnung gegen '%s' (Seed %d) ===" % [tname, rng.get_master_seed()])
	rng.shuffle("deck", enc.draw_pile)
	_fire_relics("encounter_start")
	start_turn()


func start_turn() -> void:
	enc.turn_number += 1
	enc.energy = enc.max_energy
	if not enc.has_status("propolis"):
		enc.guards = 0
	enc.cards_played_this_turn = 0
	enc.retain_hand_flag = false
	game_log.add("--- Zug %d ---" % enc.turn_number)
	_fire_relics("turn_start")
	_varroa_tick()
	_status_start_of_turn()
	_fire_varroa_threshold_relics()
	var need: int = max(0, Balance.HAND_SIZE - enc.hand.size())
	enc.draw(need, rng, game_log)
	_reveal_intent()
	game_log.add(_status_line())


func can_play(index: int) -> bool:
	if index < 0 or index >= enc.hand.size():
		return false
	var card: Dictionary = enc.hand[index]
	var def: Dictionary = content.cards.get(String(card.get("id", "")), {})
	if def.is_empty():
		return false
	return enc.energy >= CardLib.cost(def, bool(card.get("upgraded", false)))


func play_card(index: int) -> bool:
	if not can_play(index):
		return false
	var card: Dictionary = enc.hand[index]
	var upgraded := bool(card.get("upgraded", false))
	var def: Dictionary = content.cards[String(card["id"])]
	var cost := CardLib.cost(def, upgraded)
	var stores_before := enc.stores
	enc.energy -= cost
	game_log.add("Spiele '%s' (Kosten %d)" % [String(card["id"]), cost])

	var apply_double := enc.double_next
	enc.double_next = false
	var ctx := {"source_side": "colony", "double": apply_double, "exhaust": false, "retain": false}
	interp.apply_all(CardLib.effects(def, upgraded), ctx)
	enc.cards_played_this_turn += 1

	enc.hand.remove_at(index)
	if bool(ctx["exhaust"]):
		enc.exhaust_pile.append(card)
	else:
		enc.discard_pile.append(card)

	_fire_relics("on_play_card")
	if enc.stores < stores_before:
		_fire_relics("on_stores_spent")
	_check_end()
	return true


func end_turn() -> void:
	if is_over():
		return
	_fire_relics("turn_end")
	if enc.retain_hand_flag:
		enc.retain_hand_flag = false  # Behalte-Effekt gilt nur diesen Zug
	else:
		enc.discard_hand()
	_threat_act()
	_check_end()
	if not is_over():
		start_turn()


func is_over() -> bool:
	return enc.result != ""


# --- interne Schritte -------------------------------------------------------


func _varroa_tick() -> void:
	var growth := Balance.VARROA_BASE_GROWTH + (enc.varroa * Balance.VARROA_GROWTH_PCT) / 100
	if enc.dampen_turns > 0:
		growth = growth / 2
		enc.dampen_turns -= 1
	enc.varroa += growth
	game_log.add("  Varroa-Tick: +%d -> %d" % [growth, enc.varroa])


func _status_start_of_turn() -> void:
	var regen := int(enc.statuses.get("regeneration", 0))
	if regen > 0:
		enc.strength += regen
		game_log.add("  Regeneration: +%d Volksstaerke" % regen)
	for st: String in enc.scaling.keys():
		enc.add_status(st, int(enc.scaling[st]))


func _reveal_intent() -> void:
	if enc.threat == null:
		return
	var intents: Array = enc.threat.def.get("intents", [])
	var eligible: Array = []
	for it: Dictionary in intents:
		if (
			int(it.get("min_turn", 1)) <= enc.turn_number
			and int(it.get("phase", 1)) <= enc.threat.phase
		):
			eligible.append(it)
	if eligible.is_empty():
		eligible = intents
	if eligible.is_empty():
		return
	var weights: Array = []
	for it: Dictionary in eligible:
		weights.append(int(it.get("weight", 1)))
	var pick := rng.weighted_pick("threat", weights)
	enc.threat.current_intent = eligible[pick] if pick >= 0 else eligible[0]
	game_log.add("  Bedrohung kuendigt an: '%s'" % String(enc.threat.current_intent.get("id", "?")))


func _threat_act() -> void:
	if enc.threat == null or enc.threat.current_intent.is_empty():
		return
	if enc.threat.delayed_turns > 0:
		enc.threat.delayed_turns -= 1
		game_log.add("  Bedrohungsaktion verzoegert (%d)" % enc.threat.delayed_turns)
		return
	game_log.add("Bedrohung handelt: '%s'" % String(enc.threat.current_intent.get("id", "?")))
	var ctx := {"source_side": "threat"}
	interp.apply_all(enc.threat.current_intent.get("effects", []), ctx)
	enc.threat.statuses.erase("benommen")  # Schwaechung ist einmalig
	enc.threat.current_intent = {}


func _check_end() -> void:
	if enc.result != "":
		return
	if enc.threat != null and enc.threat.hp <= 0:
		enc.result = "won"
		game_log.add(">>> Begegnung gewonnen (Zug %d)" % enc.turn_number)
	elif enc.strength <= 0:
		enc.result = "lost"
		game_log.add(">>> Volk zusammengebrochen (Zug %d)" % enc.turn_number)


func _fire_relics(trigger: String) -> void:
	for relic: Dictionary in relics:
		if String(relic.get("trigger", "")) == trigger:
			var ctx := {"source_side": "colony"}
			interp.apply_all(relic.get("effects", []), ctx)


func _fire_varroa_threshold_relics() -> void:
	for relic: Dictionary in relics:
		if String(relic.get("trigger", "")) != "on_varroa_threshold":
			continue
		var rid := String(relic.get("id", ""))
		if _fired_threshold.has(rid):
			continue
		if enc.varroa >= int(relic.get("trigger_value", 0)):
			_fired_threshold[rid] = true
			var ctx := {"source_side": "colony"}
			interp.apply_all(relic.get("effects", []), ctx)
			game_log.add("  Relikt '%s' ausgeloest (Varroa-Schwelle)" % rid)


func _status_line() -> String:
	return (
		"  [Volk: St %d | Vorr %d | Varroa %d | En %d/%d | Waecht %d | Hand %d]"
		% [
			enc.strength,
			enc.stores,
			enc.varroa,
			enc.energy,
			enc.max_energy,
			enc.guards,
			enc.hand.size()
		]
	)
