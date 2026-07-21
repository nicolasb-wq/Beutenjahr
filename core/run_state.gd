class_name RunState
extends RefCounted
## Kompositions-Wurzel eines Runs: haelt Master-Seed, RNG-Stroeme und die
## Content-Datenbank zusammen und baut Begegnungen. Die Run-Struktur
## (Pfadkarte, Akte, Meta) folgt in Phase 3 — hier nur das fuer AP 1.1
## Noetige, damit eine Begegnung deterministisch aufgesetzt werden kann.

var master_seed: int = 0
var rng: RngService = null
var content: ContentDB = null
var act: int = 1


func _init(seed_value: int, content_db: ContentDB) -> void:
	master_seed = seed_value
	content = content_db
	rng = RngService.new(seed_value)


## Baut eine Begegnung aus einer Kartenliste (Instanzen via CardLib.make)
## und einer Bedrohungs-id.
func build_encounter(deck: Array, threat_id: String) -> EncounterState:
	var tdef: Dictionary = content.threats.get(threat_id, {})
	var threat := ThreatState.from_def(tdef)
	return EncounterState.create(deck, threat)


func new_engine(enc: EncounterState, relic_defs: Array = []) -> TurnEngine:
	return TurnEngine.new(enc, rng, content, GameLog.new(), relic_defs)
