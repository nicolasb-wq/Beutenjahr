class_name Loc
extends RefCounted
## i18n-Service (Block 1). Bewusst KEIN Teil des reinen Sim-Kerns: nutzt Datei-IO
## und den globalen TranslationServer. Statisch, damit UI und Tests ihn ohne
## Autoload/Node nutzen koennen.
##
## Quelle der Wahrheit: assets/i18n/<locale>.json (key -> Text). Beide Sprachen
## werden gegen Paritaet geprueft (tools/validate_i18n.py, CI). Regel ab Block 1:
## kein neuer Text ohne Key in beiden Sprachen.

const DEFAULT_LOCALE: String = "de"
const LOCALES: Array[String] = ["de", "en"]
const _DIR: String = "res://assets/i18n"

static var _tables: Dictionary = {}
static var _locale: String = DEFAULT_LOCALE
static var _loaded: bool = false


static func ensure_loaded() -> void:
	if _loaded:
		return
	for code: String in LOCALES:
		_tables[code] = _load_table(code)
	_register_translation_server()
	_loaded = true


static func t(key: String) -> String:
	ensure_loaded()
	var table: Dictionary = _tables.get(_locale, {})
	if table.has(key) and String(table[key]) != "":
		return String(table[key])
	var fallback: Dictionary = _tables.get(DEFAULT_LOCALE, {})
	if fallback.has(key) and String(fallback[key]) != "":
		return String(fallback[key])
	return key


static func set_locale(code: String) -> void:
	ensure_loaded()
	if LOCALES.has(code):
		_locale = code
		TranslationServer.set_locale(code)


static func get_locale() -> String:
	return _locale


static func available_locales() -> Array:
	return LOCALES.duplicate()


static func has_key(key: String) -> bool:
	ensure_loaded()
	var table: Dictionary = _tables.get(DEFAULT_LOCALE, {})
	return table.has(key)


static func _load_table(code: String) -> Dictionary:
	var path := "%s/%s.json" % [_DIR, code]
	var text := FileAccess.get_file_as_string(path)
	var data: Variant = JSON.parse_string(text)
	if typeof(data) == TYPE_DICTIONARY:
		return data
	push_error("Loc: konnte '%s' nicht laden" % path)
	return {}


static func _register_translation_server() -> void:
	for code: String in LOCALES:
		var translation := Translation.new()
		translation.locale = code
		var table: Dictionary = _tables.get(code, {})
		for key: String in table.keys():
			translation.add_message(key, String(table[key]))
		TranslationServer.add_translation(translation)
