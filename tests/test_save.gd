extends TestCase
## Block 2 K6/K7: atomares Save (Roundtrip) + Replay (bitidentisch).

var content: ContentDB
var config: Dictionary


func before_each() -> void:
	content = ContentDB.new()
	content.load_all()
	config = JSON.parse_string(FileAccess.get_file_as_string("res://content/config/run.json"))


func test_replay_bitidentical() -> void:
	var rc := RunController.new(2024, content, config)
	SimUtil.play_run(rc)
	var rc2 := RunController.from_save(rc.to_save(), content, config)
	assert_eq(
		JSON.stringify(rc.snapshot()),
		JSON.stringify(rc2.snapshot()),
		"Replay (Seed + Aktionsliste) reproduziert den Run bitidentisch",
	)


func test_save_roundtrip_file() -> void:
	var rc := RunController.new(55, content, config)
	SimUtil.play_run(rc, 8)  # mitten im Run ("App-Kill")
	var path := "user://test_run_save.json"
	assert_true(SaveService.save(path, rc.to_save()), "Save erfolgreich")
	var data := SaveService.load_data(path)
	assert_eq(int(data.get("schemaVersion", 0)), 1, "schemaVersion gesetzt")
	var rc2 := RunController.from_save(data, content, config)
	assert_eq(
		JSON.stringify(rc2.snapshot()),
		JSON.stringify(rc.snapshot()),
		"Laden reproduziert den Zustand"
	)


func test_save_atomic_leaves_no_tmp() -> void:
	var path := "user://test_run_save2.json"
	assert_true(SaveService.save(path, {"schemaVersion": 1, "seed": 1, "actions": []}))
	assert_false(FileAccess.file_exists(path + ".tmp"), "keine .tmp-Leiche nach atomarem Save")
	assert_true(SaveService.exists(path), "Zieldatei existiert")
