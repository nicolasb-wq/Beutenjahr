extends TestCase
## Headless-Smoke-Test der Greybox-UI: instanziiert die Szene off-tree, baut die
## UI, spielt eine Karte, beendet einen Zug, startet einen neuen Run. Faengt
## Laufzeit-/API-Fehler (falsche Node-/Enum-Namen) VOR dem Tester-Build ab.
## Prueft keine Darstellung — die bleibt Mensch-Schritt (Debug-Build).


func test_greybox_smoke() -> void:
	var gb: Control = load("res://ui/Greybox.gd").new()
	gb._ready()  # baut UI-Knoten off-tree + erste Begegnung
	assert_true(gb._engine != null, "Engine initialisiert")
	assert_true(gb._engine.enc.hand.size() > 0, "Hand gefuellt")

	var played := false
	for i in gb._engine.enc.hand.size():
		if gb._engine.can_play(i):
			gb._on_play(i)
			played = true
			break
	assert_true(played, "mindestens eine Karte spielbar")

	gb._on_end_turn()
	gb._new_encounter()
	assert_false(gb._engine.is_over(), "frischer Run laeuft")
	gb.free()
