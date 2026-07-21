class_name ContentDB
extends RefCounted
## Laedt die datengetriebenen Content-JSONs (Karten/Bedrohungen/Ereignisse/
## Relikte) von res://content in Dictionaries (id -> Definition).
##
## Die JSONs werden in CI/lokal separat gegen das Schema validiert
## (tools/validate_content.py). Hier wird nur geladen, nicht validiert.

var cards: Dictionary = {}
var threats: Dictionary = {}
var events: Dictionary = {}
var relics: Dictionary = {}


func load_all(base: String = "res://content") -> void:
	cards = _load_dir(base + "/cards")
	threats = _load_dir(base + "/threats")
	events = _load_dir(base + "/events")
	relics = _load_dir(base + "/relics")


func _load_dir(path: String) -> Dictionary:
	var out: Dictionary = {}
	var dir := DirAccess.open(path)
	if dir == null:
		push_error("ContentDB: Verzeichnis nicht ladbar: " + path)
		return out
	dir.list_dir_begin()
	var fname := dir.get_next()
	while fname != "":
		if not dir.current_is_dir() and fname.ends_with(".json"):
			var text := FileAccess.get_file_as_string(path + "/" + fname)
			var data: Variant = JSON.parse_string(text)
			if typeof(data) == TYPE_DICTIONARY and data.has("id"):
				out[String(data["id"])] = data
			else:
				push_error("ContentDB: ungueltiges JSON in " + fname)
		fname = dir.get_next()
	dir.list_dir_end()
	return out
