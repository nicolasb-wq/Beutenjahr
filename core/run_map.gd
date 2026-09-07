class_name RunMap
extends RefCounted
## Seeded Knoten-Graph eines Akts (Block 2 / Blueprint AP 3.1). Reihen von Knoten;
## der Spieler waehlt je Reihe einen Knoten. Kanten sind v1 implizit
## voll-verbunden zwischen benachbarten Reihen (Reihe r -> alle Knoten r+1) — die
## bedeutsame Entscheidung ist der Knotentyp; Pfad-Garantien schaerfen wir spaeter.
##
## Garantien: letzte Reihe = genau 1 Boss; >=1 Shop-Knoten je Akt; jede Reihe
## erreichbar. Determinismus: gleicher Seed + Akt -> identischer Graph (Strom `map`).
##
## Knoten: { "row": int, "index": int, "type": String, "threat_id": String }
## type in { "encounter", "event", "shop", "boss" }.

const WIDTH: int = 2

var act: int = 1
var season: String = ""
var rows: Array = []


static func generate(rng: RngService, act_num: int, config: Dictionary) -> RunMap:
	var m := RunMap.new()
	m.act = act_num
	var seasons: Array = config.get("act_seasons", [])
	m.season = String(seasons[act_num - 1]) if act_num - 1 < seasons.size() else ""

	var rows_n: int = int(config.get("rows_per_act", 6))
	var akey := str(act_num)
	var boss_id := String(config.get("act_bosses", {}).get(akey, ""))
	var threats: Array = config.get("act_threats", {}).get(akey, [])

	# Genau einen Shop-Knoten platzieren (mittlere Reihe), Rest zufaellig.
	var shop_row: int = 1
	if rows_n >= 3:
		shop_row = rng.randi_range("map", 1, rows_n - 2)

	for r in rows_n:
		if r == rows_n - 1:
			m.rows.append([_node(r, 0, "boss", boss_id)])
			continue
		var row: Array = []
		for i in WIDTH:
			var node_type := "shop" if (r == shop_row and i == 0) else _pick_type(rng)
			var threat_id := ""
			if node_type == "encounter" and not threats.is_empty():
				threat_id = String(threats[rng.randi_range("map", 0, threats.size() - 1)])
			row.append(_node(r, i, node_type, threat_id))
		m.rows.append(row)
	return m


static func _node(r: int, i: int, node_type: String, threat_id: String) -> Dictionary:
	return {"row": r, "index": i, "type": node_type, "threat_id": threat_id}


static func _pick_type(rng: RngService) -> String:
	# encounter (Gewicht 3) vs event (Gewicht 2); Shop wird separat platziert.
	return "encounter" if rng.weighted_pick("map", [3, 2]) == 0 else "event"


func row_count() -> int:
	return rows.size()


func nodes_in_row(r: int) -> Array:
	return rows[r]


func has_shop() -> bool:
	for row: Array in rows:
		for node: Dictionary in row:
			if String(node.get("type", "")) == "shop":
				return true
	return false


## Kompakte Typ-Uebersicht je Reihe (Determinismus-/Debug-Vergleich).
func type_grid() -> Array:
	var grid: Array = []
	for row: Array in rows:
		var types: Array = []
		for node: Dictionary in row:
			types.append(String(node.get("type", "")))
		grid.append(types)
	return grid
