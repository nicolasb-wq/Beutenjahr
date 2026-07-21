extends SceneTree
## Headless-Test-Runner. Start:  godot --headless --script res://tests/run_tests.gd
## Exit-Code 0 = alle gruen, 1 = Fehler (CI-Bedingung).
##
## Robustheit: die eigentliche Arbeit laeuft in _initialize(); _process() gibt
## true zurueck und beendet den MainLoop garantiert nach dem ersten Frame
## (verhindert Idle-Hang, falls quit() im _initialize nicht sofort greift).

const SUITES: Array = [
	preload("res://tests/test_rng.gd"),
	preload("res://tests/test_interpreter.gd"),
	preload("res://tests/test_interpreter_ops.gd"),
	preload("res://tests/test_turn_engine.gd"),
	preload("res://tests/test_threat_ai.gd"),
	preload("res://tests/test_autoplayer.gd"),
	preload("res://tests/test_determinism.gd"),
]


func _initialize() -> void:
	var failures := _run_all()
	quit(1 if failures > 0 else 0)


func _process(_delta: float) -> bool:
	return true  # Backstop: nach dem ersten Frame beenden


func _run_all() -> int:
	var total_tests := 0
	var all_failures: Array = []
	for suite_script: GDScript in SUITES:
		var inst: TestCase = suite_script.new()
		var res: Dictionary = inst.run()
		total_tests += int(res["count"])
		var fails: Array = res["failures"]
		var status := "OK   " if fails.is_empty() else "FEHLER"
		print(
			"[%s] %-24s %2d Tests, %d Fehler" % [status, res["suite"], res["count"], fails.size()]
		)
		all_failures.append_array(fails)
	print("----------------------------------------------")
	if all_failures.is_empty():
		print("ALLE %d TESTS GRUEN" % total_tests)
		return 0
	for f in all_failures:
		printerr("  FAIL " + str(f))
	print("%d FEHLER von %d Tests" % [all_failures.size(), total_tests])
	return all_failures.size()
