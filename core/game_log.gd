class_name GameLog
extends RefCounted
## Sammelt Textzeilen des Sim-Kerns (Konsolen-Demo, spaeter Basis der
## Niederlagen-Analyse in Phase 4). Reiner Datensammler, keine Ausgabe.

var lines: Array[String] = []


func add(line: String) -> void:
	lines.append(line)


func as_text() -> String:
	return "\n".join(lines)


func clear() -> void:
	lines.clear()
