extends TestCase
## Determinismus-Doppellauf (DoD AP 1.1): gleicher Seed + gleiche Politik
## -> bitidentischer Zustands-Snapshot und identisches Log.

var content: ContentDB


func before_each() -> void:
	content = ContentDB.new()
	content.load_all()


func _run(seed_value: int) -> Dictionary:
	var run := RunState.new(seed_value, content)
	var deck: Array = []
	for _i in 12:
		deck.append(CardLib.make("sammelflug"))
	deck.append(CardLib.make("sammelmotor"))
	deck.append(CardLib.make("oxalsaeure_traeufeln"))
	var enc := run.build_encounter(deck, "schwarmereignis")
	var engine := run.new_engine(enc, [content.relics.get("beutenbock", {})])
	SimUtil.play_first_playable(engine, 8)
	return {"snap": JSON.stringify(engine.enc.snapshot()), "log": engine.game_log.as_text()}


func test_double_run_identical() -> void:
	var a := _run(12345)
	var b := _run(12345)
	assert_eq(a["snap"], b["snap"], "Snapshot bitidentisch")
	assert_eq(a["log"], b["log"], "Log identisch")


func test_different_seed_differs() -> void:
	var a := _run(1)
	var b := _run(2)
	assert_ne(a["snap"], b["snap"], "andere Seeds -> anderer Verlauf")
