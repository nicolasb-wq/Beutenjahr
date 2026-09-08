extends TestCase
## Signaturmechanik: Milbendruck (ADR-0004). Sichert die Schwellen [8,14,20]
## gegen Off-by-One und den Boden-bei-Null von _colony_out ab. Diese Zahlen
## verschieben die gesamte Schwierigkeitskurve — hier verriegelt, damit ein
## versehentliches Verschieben der Schwelle als roter Test auffaellt.

var enc: EncounterState
var rng: RngService
var interp: EffectInterpreter


func before_each() -> void:
	rng = RngService.new(1)
	var threat := ThreatState.from_def({"id": "t", "hp": 30})
	enc = EncounterState.create([], threat)
	interp = EffectInterpreter.new(enc, rng, GameLog.new())


func _apply(effect: Dictionary, side: String = "colony") -> void:
	interp.apply(effect, {"source_side": side, "double": false})


## Reine Funktion: Anzahl erreichter/ueberschrittener Schwellen (0..3).
func test_pressure_boundaries_exact() -> void:
	var cases: Array = [
		[0, 0],
		[7, 0],  # knapp unter erster Schwelle
		[8, 1],  # erste Schwelle erreicht
		[13, 1],  # knapp unter zweiter
		[14, 2],  # zweite erreicht
		[19, 2],  # knapp unter dritter
		[20, 3],  # dritte erreicht
		[21, 3],
		[100, 3],  # deckelt bei 3
	]
	for pair: Array in cases:
		var varroa: int = pair[0]
		var expected: int = pair[1]
		assert_eq(Balance.varroa_pressure(varroa), expected, "varroa=%d" % varroa)


func test_pressure_zero_below_first_threshold() -> void:
	# Direkt unter der ersten Schwelle darf NICHTS gesenkt werden.
	enc.varroa = 7
	enc.guards = 0
	_apply({"op": "gain_guards", "value": 6})
	assert_eq(enc.guards, 6, "varroa 7 -> Druck 0, keine Senkung")


func test_pressure_one_below_second_threshold() -> void:
	# 13 liegt noch in Druckstufe 1 (nicht 2) — verriegelt die zweite Schwelle.
	enc.varroa = 13
	enc.guards = 0
	_apply({"op": "gain_guards", "value": 6})
	assert_eq(enc.guards, 5, "varroa 13 -> Druck 1")


func test_pressure_two_below_third_threshold() -> void:
	# 19 liegt noch in Druckstufe 2 (nicht 3) — verriegelt die dritte Schwelle.
	enc.varroa = 19
	enc.guards = 0
	_apply({"op": "gain_guards", "value": 6})
	assert_eq(enc.guards, 4, "varroa 19 -> Druck 2")


func test_colony_out_floors_at_zero() -> void:
	# Druck darf die Wirkung nicht ins Negative druecken.
	enc.varroa = 20  # Druck 3
	enc.stores = 0
	_apply({"op": "gain_stores", "value": 2})
	assert_eq(enc.stores, 0, "2 - 3 -> Boden bei 0, nicht -1")


func test_pressure_reduces_damage_to_threat() -> void:
	# Ausgehender Schaden aufs Volk-Konto wird ebenfalls gesenkt.
	enc.varroa = 8  # Druck 1
	enc.threat.hp = 30
	_apply({"op": "deal_damage", "value": 6, "target": "threat"})
	assert_eq(enc.threat.hp, 25, "30 - (6-1)")


func test_pressure_reduces_heal_colony() -> void:
	enc.varroa = 14  # Druck 2
	enc.strength = 10
	_apply({"op": "heal", "value": 6})
	assert_eq(enc.strength, 14, "10 + (6-2)")


func test_treatment_not_reduced_reduce_varroa() -> void:
	enc.varroa = 20  # Druck 3
	_apply({"op": "reduce_varroa", "value": 5})
	assert_eq(enc.varroa, 15, "Behandlung wird nie gesenkt (keine Todesspirale)")


func test_treatment_not_reduced_dampen() -> void:
	enc.varroa = 20  # Druck 3
	enc.dampen_turns = 0
	_apply({"op": "dampen_varroa", "value": 3})
	assert_eq(enc.dampen_turns, 3, "Daempfung umgeht Milbendruck")


func test_threat_source_damage_ignores_colony_pressure() -> void:
	# Milbendruck senkt NUR volk-ausgehende Wirkungen. Eingehender
	# Bedrohungsschaden bleibt von der eigenen Varroa unberuehrt.
	enc.varroa = 20  # Druck 3 (Volk)
	enc.strength = 20
	enc.guards = 0
	enc.threat.escalation_bonus = 0
	_apply({"op": "deal_damage", "value": 8, "target": "colony"}, "threat")
	assert_eq(enc.strength, 12, "20 - 8, ungesenkt")
