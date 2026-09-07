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


## Autoplayer v0 (ADR-0004): spielt je Zug eine zufaellige legale Karte, bis
## keine mehr legal ist, dann Zugende. Eigener seeded RNG (Policy ist Eingabe,
## nicht Spielzustand). Zweck: Crashfreiheit-Nachweis; der Balancing-Bot folgt
## in Phase 4.
static func play_random_legal(engine: TurnEngine, policy_seed: int, max_turns: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = policy_seed
	engine.start_encounter()
	var guard := 0
	while not engine.is_over() and engine.enc.turn_number <= max_turns:
		var legal: Array = []
		for i in engine.enc.hand.size():
			if engine.can_play(i):
				legal.append(i)
		if legal.is_empty():
			engine.end_turn()
		else:
			engine.play_card(legal[rng.randi_range(0, legal.size() - 1)])
		guard += 1
		if guard > _GUARD_LIMIT:
			return


## Deterministische Run-Politik (Block 2): treibt einen RunController durch einen
## ganzen Run. Karte: immer erster Knoten; Begegnung: erste spielbare Karte, sonst
## Zugende; Ereignis/Belohnung: Option 0; Shop: verlassen. Fuer Tests/Smoke.
static func play_run(rc: RunController, max_steps: int = 5000) -> void:
	var guard := 0
	while not rc.is_finished() and guard < max_steps:
		guard += 1
		match rc.phase:
			"map":
				if rc.available_nodes().is_empty():
					return
				rc.choose_node(0)
			"encounter":
				var progress := false
				for i in rc.engine.enc.hand.size():
					if rc.engine.can_play(i):
						rc.play_card(i)
						progress = true
						break
				if not progress and rc.phase == "encounter":
					rc.end_turn()
			"event":
				rc.choose_event_option(0)
			"shop":
				rc.shop_leave()
			"reward":
				rc.choose_reward(0)
			_:
				return
