class_name EncounterState
extends RefCounted
## Vollstaendiger Zustand einer Begegnung. Reine Daten + Stapel-Operationen,
## kein Node-Zugriff (ADR-0001). Effekte werden vom EffectInterpreter
## angewandt, der Ablauf von der TurnEngine gesteuert.

var strength: int = 0
var stores: int = 0
var varroa: int = 0
var energy: int = 0
var max_energy: int = 0
var guards: int = 0
var turn_number: int = 0
var cards_played_this_turn: int = 0
var dampen_turns: int = 0
var double_next: bool = false
var retain_hand_flag: bool = false
var scry_reveal: Array = []  # ids der zuletzt per scry enthuellten Karten (UI/Autoplayer-Seam)

# Karteninstanzen ({id, upgraded, ...}) in den Stapeln.
var hand: Array = []
var draw_pile: Array = []
var discard_pile: Array = []
var exhaust_pile: Array = []

var statuses: Dictionary = {}  # colony-Status -> Stapel
var scaling: Dictionary = {}  # status -> Zuwachs pro Runde (scale_per_turn)
var flags: Dictionary = {}  # z. B. brood_free

var threat: ThreatState = null
var result: String = ""  # "" | "won" | "lost" | "fled"
var reward_choices: Array = []  # bei Sieg: bis zu 3 Karten-ids zur Auswahl


static func create(deck: Array, threat_state: ThreatState) -> EncounterState:
	var e := EncounterState.new()
	e.strength = Balance.START_STRENGTH
	e.stores = Balance.START_STORES
	e.varroa = Balance.START_VARROA
	e.max_energy = Balance.START_MAX_ENERGY
	e.energy = Balance.START_MAX_ENERGY
	e.threat = threat_state
	e.draw_pile = deck.duplicate(true)
	return e


## Begegnung aus dem persistenten Volkszustand (Block 2): Volksstaerke/Vorraete/
## Varroa/max_energy/Deck stammen vom Volk.
static func from_colony(colony: ColonyState, threat_state: ThreatState) -> EncounterState:
	var e := EncounterState.new()
	e.strength = colony.strength
	e.stores = colony.stores
	e.varroa = colony.varroa
	e.max_energy = colony.max_energy
	e.energy = colony.max_energy
	e.threat = threat_state
	e.draw_pile = colony.deck.duplicate(true)
	return e


## Schreibt persistente Ressourcen zurueck ins Volk (nach Begegnungsende).
func write_back(colony: ColonyState) -> void:
	colony.strength = strength
	colony.stores = stores
	colony.varroa = varroa


func has_status(name: String) -> bool:
	return int(statuses.get(name, 0)) > 0


func add_status(name: String, stacks: int) -> void:
	statuses[name] = int(statuses.get(name, 0)) + stacks


func reshuffle(rng: RngService, game_log: GameLog) -> void:
	draw_pile = discard_pile.duplicate()
	discard_pile.clear()
	rng.shuffle("deck", draw_pile)
	game_log.add("  (Ablagestapel neu gemischt: %d Karten)" % draw_pile.size())


func draw(count: int, rng: RngService, game_log: GameLog) -> int:
	var drawn := 0
	for _i in count:
		if draw_pile.is_empty():
			if discard_pile.is_empty():
				break
			reshuffle(rng, game_log)
		if draw_pile.is_empty():
			break
		hand.append(draw_pile.pop_back())
		drawn += 1
	return drawn


func discard_hand() -> void:
	for card in hand:
		discard_pile.append(card)
	hand.clear()


func snapshot() -> Dictionary:
	return {
		"strength": strength,
		"stores": stores,
		"varroa": varroa,
		"energy": energy,
		"max_energy": max_energy,
		"guards": guards,
		"turn": turn_number,
		"dampen_turns": dampen_turns,
		"double_next": double_next,
		"retain_hand": retain_hand_flag,
		"scry_reveal": scry_reveal.duplicate(),
		"hand": _pile_ids(hand),
		"draw": _pile_ids(draw_pile),
		"discard": _pile_ids(discard_pile),
		"exhaust": _pile_ids(exhaust_pile),
		"statuses": statuses.duplicate(true),
		"scaling": scaling.duplicate(true),
		"flags": flags.duplicate(true),
		"threat": threat.snapshot() if threat != null else {},
		"result": result,
		"reward_choices": reward_choices.duplicate(),
	}


func _pile_ids(pile: Array) -> Array:
	var out: Array = []
	for card in pile:
		var mark: String = "+" if bool(card.get("upgraded", false)) else ""
		out.append(String(card.get("id", "?")) + mark)
	return out
