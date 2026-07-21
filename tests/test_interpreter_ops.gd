extends TestCase
## Interpreter-Tests, Teil 2: restliche Primitive + Kombinationen/Reihenfolge.
## (Aufgeteilt von test_interpreter.gd wegen gdlint max-public-methods.)

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


func _apply_ctx(effect: Dictionary, side: String = "colony") -> Dictionary:
	var ctx := {"source_side": side, "double": false, "exhaust": false, "retain": false}
	interp.apply(effect, ctx)
	return ctx


func test_gain_energy() -> void:
	enc.energy = 1
	_apply({"op": "gain_energy", "value": 2})
	assert_eq(enc.energy, 3)


func test_gain_max_energy() -> void:
	enc.max_energy = 3
	enc.energy = 3
	_apply({"op": "gain_max_energy", "value": 2})
	assert_eq(enc.max_energy, 5)
	assert_eq(enc.energy, 5, "sofort nutzbar")


func test_dampen_varroa_sets_turns() -> void:
	enc.dampen_turns = 0
	_apply({"op": "dampen_varroa", "value": 3})
	assert_eq(enc.dampen_turns, 3)


func test_weaken_threat_adds_benommen() -> void:
	_apply({"op": "weaken_threat", "value": 4})
	assert_eq(int(enc.threat.statuses.get("benommen", 0)), 4)


func test_delay_intent() -> void:
	_apply({"op": "delay_intent", "value": 2})
	assert_eq(enc.threat.delayed_turns, 2)


func test_discard_random_removes() -> void:
	enc.hand = [CardLib.make("a"), CardLib.make("b"), CardLib.make("c")]
	_apply({"op": "discard", "value": 2})
	assert_eq(enc.hand.size(), 1)
	assert_eq(enc.discard_pile.size(), 2)


func test_discard_all() -> void:
	enc.hand = [CardLib.make("a"), CardLib.make("b")]
	_apply({"op": "discard", "value": 0, "select": "all"})
	assert_eq(enc.hand.size(), 0)
	assert_eq(enc.discard_pile.size(), 2)


func test_exhaust_self_sets_ctx() -> void:
	var ctx := _apply_ctx({"op": "exhaust_self"})
	assert_true(bool(ctx["exhaust"]))


func test_heal_start_of_turn_adds_regeneration() -> void:
	_apply({"op": "heal_start_of_turn", "value": 3})
	assert_eq(int(enc.statuses.get("regeneration", 0)), 3)


func test_double_next_op_sets_flag() -> void:
	enc.double_next = false
	_apply({"op": "double_next"})
	assert_true(enc.double_next)


func test_retain_hand_sets_flag() -> void:
	enc.retain_hand_flag = false
	_apply({"op": "retain_hand"})
	assert_true(enc.retain_hand_flag)


func test_scry_reveals_top() -> void:
	enc.draw_pile = [CardLib.make("x"), CardLib.make("y"), CardLib.make("z")]
	_apply({"op": "scry", "value": 2})
	assert_eq(enc.scry_reveal, ["z", "y"], "oberste 2 (Stapelende) enthüllt")
	assert_eq(enc.draw_pile.size(), 3, "Ziehstapel unverändert")


func test_double_next_after_scale() -> void:
	enc.stores = 10
	enc.guards = 0
	_apply(
		{"op": "gain_guards", "value": 1, "scale": {"per": "stores", "factor": 1}}, "colony", true
	)
	assert_eq(enc.guards, 22, "(1 + 10*1) * 2")


func test_benommen_reduces_threat_damage() -> void:
	enc.strength = 20
	enc.guards = 0
	enc.threat.statuses["benommen"] = 3
	_apply({"op": "deal_damage", "value": 8, "target": "colony"}, "threat")
	assert_eq(enc.strength, 15, "8 - 3 benommen")
