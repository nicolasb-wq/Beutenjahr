class_name EffectInterpreter
extends RefCounted
## Wendet ein einzelnes Effekt-Objekt (Content-Schema §2) auf den
## Begegnungszustand an. Kennt alle 25 Primitive + die Modifikatoren
## `scale` und `condition`.
##
## Reine Zustandsmaschine: mutiert `enc`, nutzt `rng` fuer alles Zufaellige,
## schreibt Textzeilen in `game_log`. Kein Node-Zugriff.
##
## ctx (Dictionary): {
##   "source_side": "colony" | "threat"  (wer den Effekt ausloest),
##   "double": bool                       (naechste-Karte-verdoppeln aktiv),
##   "exhaust": bool (out),               (Karte nach Spielen entfernen),
##   "retain": bool (out)                 (Karte behalten — v1 begrenzt),
## }

var enc: EncounterState
var rng: RngService
var game_log: GameLog


func _init(encounter: EncounterState, rng_service: RngService, log_sink: GameLog) -> void:
	enc = encounter
	rng = rng_service
	game_log = log_sink


func apply_all(effects: Array, ctx: Dictionary) -> void:
	for effect in effects:
		apply(effect, ctx)


func apply(effect: Dictionary, ctx: Dictionary) -> void:
	if effect.has("condition") and not _check_condition(effect["condition"]):
		return
	var op := String(effect.get("op", ""))
	var target := String(effect.get("target", "colony"))
	var colony_source: bool = String(ctx.get("source_side", "colony")) == "colony"
	var value := _resolve_value(effect, ctx)

	match op:
		"gain_stores":
			if colony_source:
				value += int(enc.statuses.get("sammeltrieb", 0))
			enc.stores += _colony_out(value, colony_source)
		"spend_stores":
			enc.stores = max(0, enc.stores - value)
		"heal":
			if target == "threat" and enc.threat != null:
				enc.threat.hp = min(enc.threat.max_hp, enc.threat.hp + value)
			else:
				enc.strength += _colony_out(value, colony_source)
		"gain_energy":
			enc.energy += value
		"gain_max_energy":
			enc.max_energy += value
			enc.energy += value
		"gain_guards":
			enc.guards += _colony_out(value, colony_source)
		"add_varroa":
			enc.varroa += value
		"reduce_varroa":
			enc.varroa = max(0, enc.varroa - value)
		"dampen_varroa":
			enc.dampen_turns += value
		"deal_damage":
			_deal_damage(target, value, colony_source)
		"weaken_threat":
			if enc.threat != null:
				enc.threat.statuses["benommen"] = (
					int(enc.threat.statuses.get("benommen", 0)) + value
				)
		"delay_intent":
			if enc.threat != null:
				enc.threat.delayed_turns += value
		"draw":
			enc.draw(value, rng, game_log)
		"discard":
			_discard(effect, value)
		"generate_card":
			var cid := String(effect.get("card_id", ""))
			if cid != "":
				enc.hand.append(CardLib.make(cid))
		"exhaust_self":
			ctx["exhaust"] = true
		"retain_hand":
			# Die restliche Hand wird am Zugende NICHT abgelegt (Behalte-Keyword).
			enc.retain_hand_flag = true
		"scry":
			_scry(value)
		"apply_status":
			_status_bag(target)[String(effect.get("status", ""))] = (
				_status_get(target, effect) + value
			)
		"remove_status":
			_status_bag(target).erase(String(effect.get("status", "")))
		"scale_per_turn":
			var st := String(effect.get("status", ""))
			enc.scaling[st] = int(enc.scaling.get(st, 0)) + value
			enc.add_status(st, value)
		"heal_start_of_turn":
			enc.add_status("regeneration", value)
		"double_next":
			enc.double_next = true
		"convert":
			_convert(effect, value)
		"custom_effect":
			_custom(String(effect.get("hook", "")))
		_:
			game_log.add("  [WARN unbekannter op: %s]" % op)


func _deal_damage(target: String, value: int, colony_source: bool) -> void:
	var dmg := value
	if target == "threat":
		if enc.threat == null:
			return
		if colony_source:
			dmg += int(enc.statuses.get("kraft", 0))
		dmg += int(enc.threat.statuses.get("markiert", 0))
		dmg = _colony_out(dmg, colony_source)  # Milbendruck senkt ausgehenden Schaden
		enc.threat.hp = max(0, enc.threat.hp - dmg)
	else:
		# Ziel colony.
		if not colony_source:
			var extra := enc.threat.escalation_bonus if enc.threat != null else 0
			var benommen := int(enc.threat.statuses.get("benommen", 0)) if enc.threat != null else 0
			dmg = max(0, dmg + extra - benommen)
			var absorbed: int = min(enc.guards, dmg)
			enc.guards -= absorbed
			enc.strength = max(0, enc.strength - (dmg - absorbed))
		else:
			# Selbstschaden (z. B. Brutverlust) umgeht Waechterinnen.
			enc.strength = max(0, enc.strength - dmg)


func _discard(effect: Dictionary, value: int) -> void:
	var select := String(effect.get("select", "random"))
	if select == "all":
		for card in enc.hand:
			enc.discard_pile.append(card)
		enc.hand.clear()
		return
	var n: int = min(value, enc.hand.size())
	for _i in n:
		var idx := rng.randi_range("deck", 0, enc.hand.size() - 1)
		enc.discard_pile.append(enc.hand[idx])
		enc.hand.remove_at(idx)


func _scry(count: int) -> void:
	# Kern-Verantwortung: die obersten Karten enthuellen (Ziehstapel-Ende =
	# oben, weil draw() per pop_back() zieht). Die Umsortier-/Ablage-Entscheidung
	# trifft die UI (Phase 5) bzw. der Autoplayer (Phase 4) ueber scry_reveal.
	enc.scry_reveal = []
	var n: int = min(count, enc.draw_pile.size())
	for k in range(enc.draw_pile.size() - 1, enc.draw_pile.size() - 1 - n, -1):
		enc.scry_reveal.append(String(enc.draw_pile[k].get("id", "?")))
	game_log.add("  scry %d: %s" % [n, str(enc.scry_reveal)])


func _convert(effect: Dictionary, value: int) -> void:
	var from := String(effect.get("from", ""))
	var to := String(effect.get("to", ""))
	var ratio: int = max(1, int(effect.get("ratio", 1)))
	var available := _resource_get(from)
	var amount: int = available if value <= 0 else min(value, available)
	_resource_add(from, -amount)
	_resource_add(to, amount / ratio)


func _custom(hook: String) -> void:
	match hook:
		"halbiere_varroa_wachstum":
			enc.dampen_turns += 2
		_:
			game_log.add("  [custom_effect: unbekannter hook '%s' (v1 no-op)]" % hook)


func _resolve_value(effect: Dictionary, ctx: Dictionary) -> int:
	var v := int(effect.get("value", 0))
	if effect.has("scale"):
		var per := String(effect["scale"].get("per", ""))
		var factor := int(effect["scale"].get("factor", 0))
		v += _metric(per) * factor
	if bool(ctx.get("double", false)):
		v *= 2
	return v


## Senkt vom Volk ausgehende Wirkungen um den Milbendruck (ADR-0004).
func _colony_out(base: int, colony_source: bool) -> int:
	if not colony_source:
		return base
	return max(0, base - Balance.varroa_pressure(enc.varroa))


func _metric(per: String) -> int:
	var by_name := {
		"stores": enc.stores,
		"strength": enc.strength,
		"varroa": enc.varroa,
		"guards": enc.guards,
		"hand_size": enc.hand.size(),
		"cards_played": enc.cards_played_this_turn,
	}
	return int(by_name.get(per, 0))


func _check_condition(cond: Dictionary) -> bool:
	var kind := String(cond.get("if", ""))
	var v := int(cond.get("value", 0))
	var ok := true
	match kind:
		"varroa_over":
			ok = enc.varroa > v
		"varroa_under":
			ok = enc.varroa < v
		"stores_over":
			ok = enc.stores > v
		"stores_under":
			ok = enc.stores < v
		"strength_under":
			ok = enc.strength < v
		"brood_free":
			ok = bool(enc.flags.get("brood_free", false))
		"has_status":
			var bag := _status_bag(String(cond.get("target", "colony")))
			ok = int(bag.get(String(cond.get("status", "")), 0)) > 0
	return ok


func _status_bag(target: String) -> Dictionary:
	if target == "threat" and enc.threat != null:
		return enc.threat.statuses
	return enc.statuses


func _status_get(target: String, effect: Dictionary) -> int:
	return int(_status_bag(target).get(String(effect.get("status", "")), 0))


func _resource_get(name: String) -> int:
	match name:
		"strength":
			return enc.strength
		"stores":
			return enc.stores
		"varroa":
			return enc.varroa
		"guards":
			return enc.guards
		"energy":
			return enc.energy
	return 0


func _resource_add(name: String, delta: int) -> void:
	match name:
		"strength":
			enc.strength = max(0, enc.strength + delta)
		"stores":
			enc.stores = max(0, enc.stores + delta)
		"varroa":
			enc.varroa = max(0, enc.varroa + delta)
		"guards":
			enc.guards = max(0, enc.guards + delta)
		"energy":
			enc.energy = max(0, enc.energy + delta)
