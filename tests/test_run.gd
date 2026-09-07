extends TestCase
## Block 2: RunController — voller Run, Determinismus, Einwinterung, Belohnung.

var content: ContentDB
var config: Dictionary


func before_each() -> void:
	content = ContentDB.new()
	content.load_all()
	var text := FileAccess.get_file_as_string("res://content/config/run.json")
	config = JSON.parse_string(text)


func test_full_run_finishes() -> void:
	var rc := RunController.new(12345, content, config)
	SimUtil.play_run(rc)
	assert_true(rc.is_finished(), "Run terminiert")
	assert_true(rc.phase == "wintering" or rc.phase == "dead", "Endphase korrekt")
	if rc.phase == "wintering":
		assert_true(
			rc.wintering in ["kein", "bronze", "silber", "gold"], "gueltige Einwinterungsstufe"
		)


func test_run_deterministic() -> void:
	var a := RunController.new(777, content, config)
	SimUtil.play_run(a)
	var b := RunController.new(777, content, config)
	SimUtil.play_run(b)
	assert_eq(
		JSON.stringify(a.snapshot()), JSON.stringify(b.snapshot()), "gleicher Seed -> gleicher Run"
	)


func test_reward_grows_deck() -> void:
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
	var cfg: Dictionary = config.duplicate(true)
	cfg["start_deck"] = ["_ts", "_ts", "_ts", "_ts", "_ts"]
	var rc := RunController.new(4, content, cfg)
	var start_size := rc.colony.deck.size()
	SimUtil.play_run(rc)
	assert_true(rc.colony.deck.size() > start_size, "gewonnene Belohnungen wandern ins Deck")


func test_wintering_thresholds() -> void:
	var w: Dictionary = config["wintering"]
	assert_eq(RunController.evaluate_wintering(35, 30, 5, w), "gold")
	assert_eq(RunController.evaluate_wintering(25, 20, 10, w), "silber")
	assert_eq(RunController.evaluate_wintering(15, 10, 20, w), "bronze")
	assert_eq(RunController.evaluate_wintering(5, 2, 30, w), "kein")
	assert_eq(
		RunController.evaluate_wintering(35, 30, 30, w), "kein", "hohe Varroa kippt alle Stufen"
	)
