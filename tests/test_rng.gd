extends TestCase
## RNG-Ströme: Determinismus + Unabhängigkeit (ADR-0003).


func test_same_seed_same_sequence() -> void:
	var a := RngService.new(42)
	var b := RngService.new(42)
	for _i in 20:
		assert_eq(a.randi_range("deck", 0, 1000000), b.randi_range("deck", 0, 1000000))


func test_streams_independent() -> void:
	var a := RngService.new(7)
	var b := RngService.new(7)
	var seq_a: Array = []
	for _i in 10:
		seq_a.append(a.randi_range("deck", 0, 999))
	var seq_b: Array = []
	for _i in 10:
		b.randi_range("threat", 0, 999)  # Ziehung aus anderem Strom
		seq_b.append(b.randi_range("deck", 0, 999))
	assert_eq(seq_a, seq_b, "deck-Strom unabhängig vom threat-Strom")


func test_shuffle_deterministic() -> void:
	var a := RngService.new(5)
	var b := RngService.new(5)
	var arr_a: Array = [1, 2, 3, 4, 5, 6, 7, 8]
	var arr_b: Array = [1, 2, 3, 4, 5, 6, 7, 8]
	a.shuffle("deck", arr_a)
	b.shuffle("deck", arr_b)
	assert_eq(arr_a, arr_b, "gleicher Seed -> gleiche Mischung")
	assert_eq(arr_a.size(), 8, "keine Karte verloren")


func test_weighted_pick() -> void:
	var r := RngService.new(3)
	for _i in 50:
		var idx := r.weighted_pick("event", [1, 0, 3])
		assert_true(idx == 0 or idx == 2, "0-Gewicht nie gewählt")
	assert_eq(r.weighted_pick("event", [0, 0]), -1, "nur 0-Gewichte -> -1")
