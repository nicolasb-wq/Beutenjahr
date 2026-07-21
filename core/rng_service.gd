class_name RngService
extends RefCounted
## Getrennte, seeded RNG-Stroeme (ADR-0003 / Blueprint 7.2).
##
## Ein Strom pro Subsystem: `deck`, `threat`, `event`, `map`. Getrennte
## Stroeme verhindern, dass eine zusaetzliche Ziehung in einem Subsystem
## alle Replays eines anderen verschiebt (Blueprint-Stolperfalle AP 1.1).
##
## Determinismus: gleicher `master_seed` -> identische Folgen. Kein Zugriff
## auf den globalen RNG, keine Zeit-/Frame-Abhaengigkeit.

const STREAM_NAMES: Array[String] = ["deck", "threat", "event", "map", "reward"]

var _streams: Dictionary = {}
var _master_seed: int = 0


func _init(master_seed: int = 0) -> void:
	_master_seed = master_seed
	for i in STREAM_NAMES.size():
		var rng := RandomNumberGenerator.new()
		rng.seed = _derive_seed(master_seed, i)
		_streams[STREAM_NAMES[i]] = rng


## Deterministische, stromgetrennte Seed-Ableitung (64-bit, wrap-around ok).
func _derive_seed(master_seed: int, index: int) -> int:
	var h: int = master_seed ^ ((index + 1) * 0x27d4eb2d)
	h = h * 1103515245 + 12345
	h ^= (h >> 16)
	return h & 0x7fffffffffffffff


func get_master_seed() -> int:
	return _master_seed


## Ganzzahl in [from, to] (inklusive) aus dem benannten Strom.
func randi_range(stream: String, from: int, to: int) -> int:
	return _stream(stream).randi_range(from, to)


## In-place Fisher-Yates auf dem benannten Strom. NIE Array.shuffle()
## verwenden (nutzt den globalen RNG -> nicht deterministisch).
func shuffle(stream: String, arr: Array) -> void:
	var rng := _stream(stream)
	for i in range(arr.size() - 1, 0, -1):
		var j: int = rng.randi_range(0, i)
		var tmp: Variant = arr[i]
		arr[i] = arr[j]
		arr[j] = tmp


## Gewichtete Auswahl: gibt den Index in `weights` zurueck. Leeres/0-Gewicht
## -> -1. Deterministisch ueber den benannten Strom.
func weighted_pick(stream: String, weights: Array) -> int:
	var total: int = 0
	for w in weights:
		total += int(w)
	if total <= 0:
		return -1
	var roll: int = _stream(stream).randi_range(1, total)
	var acc: int = 0
	for i in weights.size():
		acc += int(weights[i])
		if roll <= acc:
			return i
	return weights.size() - 1


## Snapshot der Stromzustaende (fuer Save/Determinismus-Vergleich).
func snapshot() -> Dictionary:
	var out: Dictionary = {"master_seed": _master_seed, "streams": {}}
	for name in STREAM_NAMES:
		var rng: RandomNumberGenerator = _streams[name]
		out["streams"][name] = {"seed": rng.seed, "state": rng.state}
	return out


func _stream(stream: String) -> RandomNumberGenerator:
	assert(_streams.has(stream), "Unbekannter RNG-Strom: " + stream)
	return _streams[stream]
