extends SceneTree
## Konsolen-Demo (DoD AP 1.1). Start:
##   godot --headless --script res://tools/demo.gd
## Spielt eine Begegnung mit der einfachen "erste spielbare Karte"-Politik und
## gibt das Textprotokoll aus.


func _initialize() -> void:
	var content := ContentDB.new()
	content.load_all()
	var run := RunState.new(20260721, content)
	var deck: Array = []
	for _i in 10:
		deck.append(CardLib.make("sammelflug"))
	deck.append(CardLib.make("sammelmotor"))
	deck.append(CardLib.make("oxalsaeure_traeufeln"))
	var enc := run.build_encounter(deck, "schwarmereignis")
	var engine := run.new_engine(enc, [content.relics.get("beutenbock", {})])
	SimUtil.play_first_playable(engine, 6)
	print(engine.game_log.as_text())
	print("\nErgebnis: %s" % (enc.result if enc.result != "" else "offen (Zuglimit erreicht)"))
	quit(0)
