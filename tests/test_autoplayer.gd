extends TestCase
## AP 1.3 DoD: Autoplayer v0 uebersteht 100 Begegnungen ohne Crash.

const THREATS: Array = ["schwarmereignis", "raeuberei_welle", "varroa_kollaps"]
const DECK: Array = ["sammelflug", "sammelmotor", "oxalsaeure_traeufeln"]

var content: ContentDB


func before_each() -> void:
	content = ContentDB.new()
	content.load_all()


func _build(game_seed: int, threat_id: String) -> TurnEngine:
	var run := RunState.new(game_seed, content)
	var deck: Array = []
	for i in 12:
		deck.append(CardLib.make(DECK[i % DECK.size()]))
	return run.new_engine(run.build_encounter(deck, threat_id), [])


func test_autoplayer_100_encounters_no_crash() -> void:
	var terminated := 0
	for s in 100:
		var e := _build(s * 7 + 1, THREATS[s % THREATS.size()])
		SimUtil.play_random_legal(e, s * 13 + 5, 40)
		if e.is_over() or e.enc.turn_number > 40:
			terminated += 1
	assert_eq(terminated, 100, "alle 100 Begegnungen terminieren ohne Crash")


func test_autoplayer_deterministic() -> void:
	var a := _build(4242, "varroa_kollaps")
	SimUtil.play_random_legal(a, 99, 40)
	var b := _build(4242, "varroa_kollaps")
	SimUtil.play_random_legal(b, 99, 40)
	assert_eq(
		JSON.stringify(a.enc.snapshot()),
		JSON.stringify(b.enc.snapshot()),
		"gleicher Spiel- und Policy-Seed -> identischer Verlauf"
	)
