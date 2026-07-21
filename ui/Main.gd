extends Control
## Platzhalter-Einstiegsszene (Phase 0).
##
## Zweck: beweist, dass das Projekt laedt und eine leere Szene laeuft
## (DoD AP 0.2). Die echte UI entsteht ab Phase 5. Der Sim-Kern in
## `core/` bleibt strikt headless und kennt diese Szene nicht.


func _ready() -> void:
	print("Beutenjahr laeuft. Sim-Kern siehe res://core/, Tests siehe res://tests/.")
