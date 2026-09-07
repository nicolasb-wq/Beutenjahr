class_name ColonyState
extends RefCounted
## Persistenter Volkszustand ueber einen ganzen Run (Block 2). Begegnungen werden
## hieraus initialisiert und schreiben Volksstaerke/Vorraete/Varroa zurueck; Deck
## und Relikte gehoeren dem Volk. Reine Daten, headless.

var strength: int = 0
var stores: int = 0
var varroa: int = 0
var max_energy: int = 0
var deck: Array = []  # Karteninstanzen {id, upgraded}
var relics: Array = []  # Relikt-Definitionen (Dictionaries)


static func create_default(deck_instances: Array, relic_defs: Array = []) -> ColonyState:
	var c := ColonyState.new()
	c.strength = Balance.START_STRENGTH
	c.stores = Balance.START_STORES
	c.varroa = Balance.START_VARROA
	c.max_energy = Balance.START_MAX_ENERGY
	c.deck = deck_instances.duplicate(true)
	c.relics = relic_defs.duplicate(true)
	return c


func is_alive() -> bool:
	return strength > 0


func snapshot() -> Dictionary:
	var deck_ids: Array = []
	for card: Dictionary in deck:
		deck_ids.append(
			{"id": String(card.get("id", "?")), "upgraded": bool(card.get("upgraded", false))}
		)
	var relic_ids: Array = []
	for relic: Dictionary in relics:
		relic_ids.append(String(relic.get("id", "?")))
	return {
		"strength": strength,
		"stores": stores,
		"varroa": varroa,
		"max_energy": max_energy,
		"deck": deck_ids,
		"relics": relic_ids,
	}


## Baut einen ColonyState aus einem Snapshot (Save/Load). `content` loest
## Relikt-ids in Definitionen auf.
static func from_snapshot(data: Dictionary, content: ContentDB) -> ColonyState:
	var c := ColonyState.new()
	c.strength = int(data.get("strength", 0))
	c.stores = int(data.get("stores", 0))
	c.varroa = int(data.get("varroa", 0))
	c.max_energy = int(data.get("max_energy", Balance.START_MAX_ENERGY))
	for card: Dictionary in data.get("deck", []):
		c.deck.append(CardLib.make(String(card.get("id", "")), bool(card.get("upgraded", false))))
	for rid: String in data.get("relics", []):
		if content.relics.has(rid):
			c.relics.append(content.relics[rid])
	return c
