class_name ThreatState
extends RefCounted
## Laufzeitzustand einer Bedrohung waehrend einer Begegnung.

var id: String = ""
var def: Dictionary = {}
var hp: int = 0
var max_hp: int = 0
var phase: int = 1
var delayed_turns: int = 0
var current_intent: Dictionary = {}
var statuses: Dictionary = {}  # benommen / markiert / verlangsamt -> Stapel


static func from_def(threat_def: Dictionary) -> ThreatState:
	var t := ThreatState.new()
	t.id = String(threat_def.get("id", ""))
	t.def = threat_def
	t.max_hp = int(threat_def.get("hp", 1))
	t.hp = t.max_hp
	return t


func snapshot() -> Dictionary:
	return {
		"id": id,
		"hp": hp,
		"phase": phase,
		"delayed_turns": delayed_turns,
		"intent": current_intent.get("id", ""),
		"statuses": statuses.duplicate(true),
	}
