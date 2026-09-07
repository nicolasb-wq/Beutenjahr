extends TestCase
## Block 2 K1: Knoten-Graph — Determinismus + Garantien.

var config: Dictionary


func before_each() -> void:
	config = JSON.parse_string(FileAccess.get_file_as_string("res://content/config/run.json"))


func test_map_deterministic() -> void:
	var a := RunMap.generate(RngService.new(5), 1, config)
	var b := RunMap.generate(RngService.new(5), 1, config)
	assert_eq(a.type_grid(), b.type_grid(), "gleicher Seed+Akt -> gleicher Graph")


func test_boss_is_last_row() -> void:
	var m := RunMap.generate(RngService.new(9), 3, config)
	var last: Array = m.nodes_in_row(m.row_count() - 1)
	assert_eq(last.size(), 1, "Boss-Reihe hat genau 1 Knoten")
	assert_eq(String(last[0]["type"]), "boss")
	assert_eq(String(last[0]["threat_id"]), "varroa_kollaps", "Akt-3-Boss")


func test_each_act_has_shop() -> void:
	for act: int in [1, 2, 3]:
		var m := RunMap.generate(RngService.new(act * 11 + 1), act, config)
		assert_true(m.has_shop(), "Akt %d hat einen Shop" % act)


func test_row_count_matches_config() -> void:
	var m := RunMap.generate(RngService.new(1), 1, config)
	assert_eq(m.row_count(), int(config["rows_per_act"]))


func test_acts_have_different_bosses() -> void:
	var a := RunMap.generate(RngService.new(3), 1, config)
	var b := RunMap.generate(RngService.new(3), 2, config)
	var la: Dictionary = a.nodes_in_row(a.row_count() - 1)[0]
	var lb: Dictionary = b.nodes_in_row(b.row_count() - 1)[0]
	assert_ne(String(la["threat_id"]), String(lb["threat_id"]), "verschiedene Akt-Bosse")
