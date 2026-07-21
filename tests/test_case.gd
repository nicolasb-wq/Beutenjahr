class_name TestCase
extends RefCounted
## Minimaler, projekteigener Test-Harness (ADR-0001: bewusst statt GUT, weil
## externe Addons in der Cloud-Umgebung nicht ladbar sind). Assert-Fassade
## bewusst GUT-nah, damit eine spaetere Migration mechanisch bleibt.
##
## Eine Testsuite erbt von TestCase und definiert Methoden `test_*`.
## `run()` fuehrt sie aus und liefert die Fehlerliste.

var _failures: Array[String] = []
var _current: String = ""
var _count: int = 0


func run() -> Dictionary:
	_failures.clear()
	_count = 0
	for m in get_method_list():
		var mname: String = m["name"]
		if mname.begins_with("test_"):
			_current = mname
			_count += 1
			before_each()
			call(mname)
			after_each()
	return {"suite": _suite_name(), "count": _count, "failures": _failures}


func before_each() -> void:
	pass


func after_each() -> void:
	pass


func fail(msg: String) -> void:
	_failures.append("%s.%s: %s" % [_suite_name(), _current, msg])


func assert_true(cond: bool, msg: String = "") -> void:
	if not cond:
		fail("erwartet true — " + msg)


func assert_false(cond: bool, msg: String = "") -> void:
	if cond:
		fail("erwartet false — " + msg)


func assert_eq(actual: Variant, expected: Variant, msg: String = "") -> void:
	if actual != expected:
		fail("erwartet %s == %s — %s" % [str(actual), str(expected), msg])


func assert_ne(actual: Variant, expected: Variant, msg: String = "") -> void:
	if actual == expected:
		fail("erwartet %s != %s — %s" % [str(actual), str(expected), msg])


func _suite_name() -> String:
	var s: Script = get_script()
	return s.resource_path.get_file() if s != null else "TestCase"
