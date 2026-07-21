extends TestCase
## Zug-Loop-Tests gegen echten Content (ADR-0003-Reihenfolge).

var content: ContentDB


func before_each() -> void:
	content = ContentDB.new()
	content.load_all()


func _engine(seed_value: int, deck_ids: Array, threat_id: String, relics: Array = []) -> TurnEngine:
	var run := RunState.new(seed_value, content)
	var deck: Array = []
	for id: String in deck_ids:
		deck.append(CardLib.make(id))
	var enc := run.build_encounter(deck, threat_id)
	return run.new_engine(enc, relics)


func _deck_of(id: String, n: int) -> Array:
	var out: Array = []
	for _i in n:
		out.append(id)
	return out


func test_content_loads() -> void:
	assert_true(content.cards.has("sammelflug"), "Karten geladen")
	assert_true(content.threats.has("schwarmereignis"), "Bedrohungen geladen")


func test_start_turn_fills_hand_and_energy() -> void:
	var e := _engine(1, _deck_of("sammelflug", 10), "schwarmereignis")
	e.start_encounter()
	assert_eq(e.enc.energy, Balance.START_MAX_ENERGY, "Energie voll")
	assert_eq(e.enc.hand.size(), Balance.HAND_SIZE, "Hand gefüllt")
	assert_false(e.enc.threat.current_intent.is_empty(), "Intent angekündigt")


func test_varroa_ticks_on_first_turn() -> void:
	var e := _engine(1, _deck_of("sammelflug", 10), "schwarmereignis")
	e.start_encounter()
	# START_VARROA 3 -> wachstum 1 + floor(3*15/100)=1 -> 4
	assert_eq(e.enc.varroa, 4, "Varroa-Tick +1")


func test_play_sammelflug_costs_energy_gains_stores() -> void:
	var e := _engine(1, _deck_of("sammelflug", 10), "schwarmereignis")
	e.start_encounter()
	var energy_before := e.enc.energy
	var stores_before := e.enc.stores
	assert_true(e.play_card(0), "Karte spielbar")
	assert_eq(e.enc.energy, energy_before - 1, "1 Energie gezahlt")
	assert_eq(e.enc.stores, stores_before + 6, "+6 Vorräte")


func test_cannot_play_without_energy() -> void:
	var e := _engine(1, _deck_of("sammelflug", 10), "schwarmereignis")
	e.start_encounter()
	e.enc.energy = 0
	assert_false(e.can_play(0))
	assert_false(e.play_card(0))


func test_win_when_threat_dies() -> void:
	content.cards["_testschlag"] = {
		"id": "_testschlag",
		"name_key": "x",
		"text_key": "x",
		"type": "aktion",
		"cost": 0,
		"rarity": "common",
		"archetype": "neutral",
		"act": 1,
		"effects": [{"op": "deal_damage", "value": 999, "target": "threat"}],
	}
	var e := _engine(1, _deck_of("_testschlag", 5), "schwarmereignis")
	e.start_encounter()
	e.play_card(0)
	assert_eq(e.enc.result, "won")


func test_lose_when_strength_zero() -> void:
	var e := _engine(1, _deck_of("sammelflug", 5), "schwarmereignis")
	e.start_encounter()
	e.enc.strength = 1
	e.enc.threat.current_intent = {
		"id": "testhieb", "effects": [{"op": "deal_damage", "value": 8, "target": "colony"}]
	}
	e.end_turn()
	assert_eq(e.enc.result, "lost")


func test_relic_turn_start_adds_guards() -> void:
	var beutenbock: Dictionary = content.relics.get("beutenbock", {})
	assert_false(beutenbock.is_empty(), "beutenbock vorhanden")
	var e := _engine(1, _deck_of("sammelflug", 10), "schwarmereignis", [beutenbock])
	e.start_encounter()
	assert_eq(e.enc.guards, 2, "Relikt gab 2 Wächterinnen zu Zugbeginn")


func _engine_cards(seed_value: int, deck: Array, threat_id: String) -> TurnEngine:
	var run := RunState.new(seed_value, content)
	var enc := run.build_encounter(deck, threat_id)
	return run.new_engine(enc, [])


func test_upgrade_overrides_effects() -> void:
	var deck: Array = []
	for _i in 6:
		deck.append(CardLib.make("sammelflug", true))
	var e := _engine_cards(1, deck, "schwarmereignis")
	e.start_encounter()
	var stores_before := e.enc.stores
	assert_true(e.play_card(0))
	assert_eq(e.enc.stores, stores_before + 9, "geimkert: +9 statt +6")


func test_upgrade_overrides_cost() -> void:
	# sammelmotor: Basis cost 2, upgrade cost 1
	var deck: Array = []
	for _i in 6:
		deck.append(CardLib.make("sammelmotor", true))
	var e := _engine_cards(1, deck, "schwarmereignis")
	e.start_encounter()
	var energy_before := e.enc.energy
	assert_true(e.play_card(0))
	assert_eq(e.enc.energy, energy_before - 1, "geimkert kostet 1 statt 2")


func test_retain_hand_keeps_cards() -> void:
	content.cards["_retain"] = {
		"id": "_retain",
		"name_key": "x",
		"text_key": "x",
		"type": "aktion",
		"cost": 0,
		"rarity": "common",
		"archetype": "neutral",
		"act": 1,
		"effects": [{"op": "retain_hand"}],
	}
	var deck: Array = []
	for _i in 8:
		deck.append(CardLib.make("_retain"))
	var e := _engine_cards(5, deck, "schwarmereignis")
	e.start_encounter()
	e.enc.threat.current_intent = {"id": "noop", "effects": []}
	assert_true(e.play_card(0), "retain-Karte spielbar")
	e.end_turn()
	assert_eq(e.enc.discard_pile.size(), 1, "nur die gespielte Karte abgelegt, Hand behalten")
