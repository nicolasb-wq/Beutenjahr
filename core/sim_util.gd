class_name SimUtil
extends RefCounted
## Deterministische Hilfs-Spielpolitik fuer Konsolen-Demo und
## Determinismus-Test. Der echte Balancing-Autoplayer (greedy + Zufall)
## entsteht in AP 1.3 — dies ist die einfachste reproduzierbare Politik:
## "spiele die erste spielbare Karte, dann beende den Zug".

const _GUARD_LIMIT: int = 10000


static func play_first_playable(engine: TurnEngine, max_turns: int) -> void:
	engine.start_encounter()
	var guard := 0
	while not engine.is_over() and engine.enc.turn_number <= max_turns:
		var progress := true
		while progress and not engine.is_over():
			progress = false
			for i in engine.enc.hand.size():
				if engine.can_play(i):
					engine.play_card(i)
					progress = true
					break
			guard += 1
			if guard > _GUARD_LIMIT:
				return
		if engine.is_over():
			return
		engine.end_turn()
