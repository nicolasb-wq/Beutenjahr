class_name RewardUtil
extends RefCounted
## Belohnungswahl nach Sieg (ADR-0004): bis zu `count` verschiedene Karten-ids
## aus dem Nicht-`special`-Pool, seeded ueber den `reward`-Strom.
##
## Der Pool wird VOR dem Mischen sortiert -> maschinenunabhaengig deterministisch
## (DirAccess-Ladereihenfolge ist nicht garantiert). Das Anwenden aufs Run-Deck
## ist Phase 3; hier nur die Auswahl.


static func offer(rng: RngService, content: ContentDB, count: int) -> Array:
	var pool: Array = []
	for id: String in content.cards.keys():
		if id.begins_with("_"):
			continue
		var def: Dictionary = content.cards[id]
		if String(def.get("rarity", "")) == "special":
			continue
		pool.append(id)
	pool.sort()
	rng.shuffle("reward", pool)
	return pool.slice(0, min(count, pool.size()))
