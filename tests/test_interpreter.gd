extends TestCase
## Unit-Tests der Effekt-Primitive (Ausschnitt; volle 25-op-Abdeckung in AP 1.2).

var enc: EncounterState
var rng: RngService
var interp: EffectInterpreter


func before_each() -> void:
	rng = RngService.new(1)
	var threat := ThreatState.from_def({"id": "t", "hp": 30})
	enc = EncounterState.create([], threat)
	interp = EffectInterpreter.new(enc, rng, GameLog.new())


func _apply(effect: Dictionary, side: String = "colony", double: bool = false) -> void:
	interp.apply(effect, {"source_side": side, "double": double})


func test_gain_stores() -> void:
	enc.stores = 0
	_apply({"op": "gain_stores", "value": 6})
	assert_eq(enc.stores, 6)


func test_gain_stores_sammeltrieb_bonus() -> void:
	enc.stores = 0
	enc.add_status("sammeltrieb", 2)
	_apply({"op": "gain_stores", "value": 6})
	assert_eq(enc.stores, 8, "sammeltrieb +2")


func test_spend_stores_floor_zero() -> void:
	enc.stores = 3
	_apply({"op": "spend_stores", "value": 5})
	assert_eq(enc.stores, 0)


func test_heal_colony() -> void:
	enc.strength = 10
	_apply({"op": "heal", "value": 5})
	assert_eq(enc.strength, 15)


func test_heal_threat_capped() -> void:
	enc.threat.hp = 30
	_apply({"op": "heal", "value": 5, "target": "threat"})
	assert_eq(enc.threat.hp, 30, "nicht über max_hp")


func test_deal_damage_threat_kraft_markiert() -> void:
	enc.add_status("kraft", 2)
	enc.threat.statuses["markiert"] = 1
	_apply({"op": "deal_damage", "value": 5, "target": "threat"})
	assert_eq(enc.threat.hp, 22, "30 - (5+2+1)")


func test_deal_damage_colony_absorbed_by_guards() -> void:
	enc.guards = 5
	enc.strength = 20
	_apply({"op": "deal_damage", "value": 8, "target": "colony"}, "threat")
	assert_eq(enc.guards, 0)
	assert_eq(enc.strength, 17, "20 - (8-5)")


func test_self_damage_bypasses_guards() -> void:
	enc.guards = 5
	enc.strength = 20
	_apply({"op": "deal_damage", "value": 4, "target": "colony"}, "colony")
	assert_eq(enc.guards, 5, "Selbstschaden umgeht Wächterinnen")
	assert_eq(enc.strength, 16)


func test_varroa_add_and_reduce_floor() -> void:
	enc.varroa = 3
	_apply({"op": "add_varroa", "value": 2})
	assert_eq(enc.varroa, 5)
	_apply({"op": "reduce_varroa", "value": 10})
	assert_eq(enc.varroa, 0)


func test_scale_modifier() -> void:
	enc.stores = 10
	enc.guards = 0
	_apply({"op": "gain_guards", "value": 1, "scale": {"per": "stores", "factor": 1}})
	assert_eq(enc.guards, 11, "1 + 10*1")


func test_condition_brood_free() -> void:
	enc.varroa = 10
	enc.flags["brood_free"] = false
	_apply({"op": "reduce_varroa", "value": 5, "condition": {"if": "brood_free"}})
	assert_eq(enc.varroa, 10, "Bedingung falsch -> kein Effekt")
	enc.flags["brood_free"] = true
	_apply({"op": "reduce_varroa", "value": 5, "condition": {"if": "brood_free"}})
	assert_eq(enc.varroa, 5, "Bedingung wahr -> Effekt")


func test_double_next_context() -> void:
	enc.stores = 0
	_apply({"op": "gain_stores", "value": 4}, "colony", true)
	assert_eq(enc.stores, 8, "verdoppelt")


func test_convert_all_stores() -> void:
	enc.stores = 10
	enc.strength = 0
	_apply({"op": "convert", "from": "stores", "to": "strength", "ratio": 2})
	assert_eq(enc.stores, 0)
	assert_eq(enc.strength, 5, "floor(10/2)")


func test_apply_and_remove_status() -> void:
	_apply({"op": "apply_status", "status": "kraft", "value": 3})
	assert_eq(int(enc.statuses.get("kraft", 0)), 3)
	_apply({"op": "remove_status", "status": "kraft"})
	assert_false(enc.statuses.has("kraft"))


func test_scale_per_turn_registers() -> void:
	_apply({"op": "scale_per_turn", "status": "sammeltrieb", "value": 1})
	assert_eq(int(enc.statuses.get("sammeltrieb", 0)), 1, "sofort +1")
	assert_eq(int(enc.scaling.get("sammeltrieb", 0)), 1, "Zuwachs registriert")


func test_draw_from_pile() -> void:
	enc.draw_pile = [CardLib.make("a"), CardLib.make("b"), CardLib.make("c")]
	_apply({"op": "draw", "value": 2})
	assert_eq(enc.hand.size(), 2)
	assert_eq(enc.draw_pile.size(), 1)


func test_generate_card_to_hand() -> void:
	assert_eq(enc.hand.size(), 0)
	_apply({"op": "generate_card", "card_id": "sammelflug"})
	assert_eq(enc.hand.size(), 1)
	assert_eq(String(enc.hand[0]["id"]), "sammelflug")


func test_custom_effect_known_hook() -> void:
	enc.dampen_turns = 0
	_apply({"op": "custom_effect", "hook": "halbiere_varroa_wachstum"})
	assert_eq(enc.dampen_turns, 2)
