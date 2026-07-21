extends TestCase
## AP 1.3: Bedrohungs-Phasen, Eskalation, Varroa-Schwellen, Abschluss/Belohnung.

var content: ContentDB


func before_each() -> void:
	content = ContentDB.new()
	content.load_all()


func _engine(deck_id: String, threat_id: String) -> TurnEngine:
	var run := RunState.new(1, content)
	var deck: Array = []
	for _i in 10:
		deck.append(CardLib.make(deck_id))
	return run.new_engine(run.build_encounter(deck, threat_id), [])


func _fresh_enc() -> Array:
	var rng := RngService.new(1)
	var threat := ThreatState.from_def({"id": "t", "hp": 30})
	var enc := EncounterState.create([], threat)
	return [enc, EffectInterpreter.new(enc, rng, GameLog.new())]


func test_threat_phase_advances() -> void:
	var e := _engine("sammelflug", "schwarmereignis")
	e.start_encounter()
	assert_eq(e.enc.threat.phase, 1, "Runde 1 Phase 1")
	e.start_turn()
	e.start_turn()
	assert_eq(e.enc.threat.phase, 1, "Runden 1-3 Phase 1")
	e.start_turn()
	assert_eq(e.enc.threat.phase, 2, "ab Runde 4 Phase 2")


func test_escalation_bonus_per_turn() -> void:
	var e := _engine("sammelflug", "schwarmereignis")  # escalation per_turn 1
	e.start_encounter()
	e.start_turn()
	e.start_turn()
	e.start_turn()  # Runde 4
	assert_eq(e.enc.threat.escalation_bonus, 3, "(4-1)*1")


func test_escalation_adds_to_incoming_damage() -> void:
	var pair := _fresh_enc()
	var enc: EncounterState = pair[0]
	var interp: EffectInterpreter = pair[1]
	enc.strength = 20
	enc.guards = 0
	enc.threat.escalation_bonus = 4
	interp.apply({"op": "deal_damage", "value": 5, "target": "colony"}, {"source_side": "threat"})
	assert_eq(enc.strength, 11, "20 - (5+4)")


func test_varroa_pressure_reduces_colony_output() -> void:
	var pair := _fresh_enc()
	var enc: EncounterState = pair[0]
	var interp: EffectInterpreter = pair[1]
	enc.varroa = 8  # Druck 1
	enc.stores = 0
	interp.apply({"op": "gain_stores", "value": 6}, {"source_side": "colony"})
	assert_eq(enc.stores, 5, "6 - 1 Milbendruck")
	enc.varroa = 14  # Druck 2
	enc.guards = 0
	interp.apply({"op": "gain_guards", "value": 6}, {"source_side": "colony"})
	assert_eq(enc.guards, 4, "6 - 2 Milbendruck")


func test_varroa_pressure_spares_treatment() -> void:
	var pair := _fresh_enc()
	var enc: EncounterState = pair[0]
	var interp: EffectInterpreter = pair[1]
	enc.varroa = 20  # Druck 3
	interp.apply({"op": "reduce_varroa", "value": 5}, {"source_side": "colony"})
	assert_eq(enc.varroa, 15, "Behandlung wird nicht gesenkt")


func test_flee_sets_result() -> void:
	var e := _engine("sammelflug", "schwarmereignis")
	e.start_encounter()
	e.flee()
	assert_eq(e.enc.result, "fled")
	e.flee()
	assert_eq(e.enc.result, "fled", "kein Doppel-Effekt")


func test_phase_gated_intent_not_yet_active() -> void:
	var e := _engine("sammelflug", "raeuberei_welle")
	e.start_encounter()  # Runde 1, Phase 1
	assert_eq(
		String(e.enc.threat.current_intent.get("id", "")),
		"pluendern",
		"phasengated 'uebermacht' noch nicht auswählbar"
	)


func test_reward_on_win() -> void:
	content.cards["_ts"] = {
		"id": "_ts",
		"name_key": "x",
		"text_key": "x",
		"type": "aktion",
		"cost": 0,
		"rarity": "common",
		"archetype": "neutral",
		"act": 1,
		"effects": [{"op": "deal_damage", "value": 999, "target": "threat"}],
	}
	var e := _engine("_ts", "schwarmereignis")
	e.start_encounter()
	e.play_card(0)
	assert_eq(e.enc.result, "won")
	assert_eq(e.enc.reward_choices.size(), 3, "3 echte Karten im Pool")
	var uniq := {}
	for cid: String in e.enc.reward_choices:
		uniq[cid] = true
	assert_eq(uniq.size(), 3, "verschiedene Karten")


func test_reward_deterministic() -> void:
	content.cards["_ts"] = {
		"id": "_ts",
		"name_key": "x",
		"text_key": "x",
		"type": "aktion",
		"cost": 0,
		"rarity": "common",
		"archetype": "neutral",
		"act": 1,
		"effects": [{"op": "deal_damage", "value": 999, "target": "threat"}],
	}
	var a := _engine("_ts", "schwarmereignis")
	a.start_encounter()
	a.play_card(0)
	var b := _engine("_ts", "schwarmereignis")
	b.start_encounter()
	b.play_card(0)
	assert_eq(a.enc.reward_choices, b.enc.reward_choices, "gleicher Seed -> gleiche Auswahl")
