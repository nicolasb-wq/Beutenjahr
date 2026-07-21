class_name CardLib
extends RefCounted
## Statische Helfer fuer Kartendefinitionen. Eine Karteninstanz in den Stapeln
## ist ein schlankes Dictionary { "id": String, "upgraded": bool }. Die
## Definition wird in ContentDB nachgeschlagen; die "geimkert"-Variante
## (`upgrade`) ueberschreibt gesetzte Felder komplett (ADR-0003 / Schema §4.1).


static func make(id: String, upgraded: bool = false) -> Dictionary:
	return {"id": id, "upgraded": upgraded}


static func field(def: Dictionary, upgraded: bool, key: String, dflt: Variant) -> Variant:
	if upgraded and def.has("upgrade") and def["upgrade"].has(key):
		return def["upgrade"][key]
	return def.get(key, dflt)


static func cost(def: Dictionary, upgraded: bool) -> int:
	return int(field(def, upgraded, "cost", 0))


static func effects(def: Dictionary, upgraded: bool) -> Array:
	return field(def, upgraded, "effects", [])


static func card_type(def: Dictionary, upgraded: bool) -> String:
	return String(field(def, upgraded, "type", "aktion"))
