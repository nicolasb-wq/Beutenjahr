extends TestCase
## Headless-Smoke der Greybox-UI (Block 2): instanziiert off-tree und spielt einen
## GANZEN Run ueber die UI-Handler durch — exerziert alle Phasen-Ansichten
## (map/encounter/event/shop/reward/end). Faengt Laufzeit-/API-Fehler VOR dem
## Tester-Build. Darstellung bleibt Mensch-Schritt (Debug-Build).

const GREYBOX: GDScript = preload("res://ui/Greybox.gd")


func test_greybox_full_run_smoke() -> void:
	var gb: Control = GREYBOX.new()
	gb._ready()
	var guard := 0
	while not gb._rc.is_finished() and guard < 3000:
		guard += 1
		match gb._rc.phase:
			"map":
				if gb._rc.available_nodes().is_empty():
					break
				gb._on_choose_node(0)
			"encounter":
				var progress := false
				for i in gb._rc.engine.enc.hand.size():
					if gb._rc.engine.can_play(i):
						gb._on_play(i)
						progress = true
						break
				if not progress and gb._rc.phase == "encounter":
					gb._on_end_turn()
			"event":
				gb._on_event_option(0)
			"shop":
				gb._on_shop_leave()
			"reward":
				gb._on_reward(0)
			_:
				break
	assert_true(gb._rc.is_finished(), "Greybox spielt einen ganzen Run durch")
	gb.free()


func test_greybox_language_switch() -> void:
	var gb: Control = GREYBOX.new()
	gb._ready()
	var de_act: String = gb._act_label.text
	gb._on_switch_lang()
	assert_eq(Loc.get_locale(), "en", "Umschalter wechselt Locale")
	assert_ne(gb._act_label.text, de_act, "Anzeige wechselt live")
	gb._on_switch_lang()
	assert_eq(Loc.get_locale(), "de", "zurueck auf de")
	gb.free()
	Loc.set_locale("de")
