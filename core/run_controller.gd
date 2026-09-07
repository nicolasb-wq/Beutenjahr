class_name RunController
extends RefCounted
## Orchestriert einen ganzen Run (Block 2 / Blueprint Phase 3): 3 Akte ueber
## seeded Knoten-Graphen, persistenter ColonyState, Einwinterungs-Bewertung.
##
## Einziger Eingabe-Trichter: alle Spielerentscheidungen laufen ueber diese
## Methoden und werden in `actions` protokolliert -> Save = Seed + Aktionsliste,
## Replay reproduziert bitidentisch. Der Sim-Kern bleibt deterministisch.

const PHASE_MAP := "map"
const PHASE_ENCOUNTER := "encounter"
const PHASE_EVENT := "event"
const PHASE_SHOP := "shop"
const PHASE_REWARD := "reward"
const PHASE_WINTERING := "wintering"
const PHASE_DEAD := "dead"

var master_seed: int = 0
var rng: RngService
var content: ContentDB
var config: Dictionary
var colony: ColonyState
var act: int = 1
var row: int = -1
var map: RunMap
var phase: String = PHASE_MAP
var finished: bool = false
var wintering: String = ""
var engine: TurnEngine = null
var event: Dictionary = {}
var shop: Dictionary = {}
var actions: Array = []

var _node: Dictionary = {}
var _pending_boss: bool = false
var _used_events: Dictionary = {}


func _init(seed_value: int, content_db: ContentDB, config_dict: Dictionary) -> void:
	master_seed = seed_value
	content = content_db
	config = config_dict
	rng = RngService.new(seed_value)
	colony = ColonyState.create_default(_start_deck())
	_begin_act(1)


# --- Karte / Navigation ----------------------------------------------------


func available_nodes() -> Array:
	if phase != PHASE_MAP or map == null:
		return []
	var next_row := row + 1
	if next_row >= map.row_count():
		return []
	return map.nodes_in_row(next_row)


func choose_node(index: int) -> void:
	if phase != PHASE_MAP:
		return
	var nodes := available_nodes()
	if index < 0 or index >= nodes.size():
		return
	row += 1
	_node = nodes[index]
	actions.append({"a": "node", "i": index})
	_enter_node()


# --- Begegnung (Eingabe-Trichter) ------------------------------------------


func play_card(hand_index: int) -> void:
	if phase != PHASE_ENCOUNTER or engine == null:
		return
	actions.append({"a": "play", "i": hand_index})
	engine.play_card(hand_index)
	_check_encounter_end()


func end_turn() -> void:
	if phase != PHASE_ENCOUNTER or engine == null:
		return
	actions.append({"a": "end"})
	engine.end_turn()
	_check_encounter_end()


# --- Ereignis --------------------------------------------------------------


func choose_event_option(index: int) -> void:
	if phase != PHASE_EVENT:
		return
	var options: Array = event.get("options", [])
	if index < 0 or index >= options.size():
		return
	actions.append({"a": "event", "i": index})
	_apply_colony_effects(options[index].get("effects", []))
	_continue_after_node(false)


# --- Imkerbesuch (Shop) ----------------------------------------------------


func shop_remove_card(deck_index: int) -> void:
	if phase != PHASE_SHOP or deck_index < 0 or deck_index >= colony.deck.size():
		return
	if colony.stores < int(shop.get("remove_cost", 0)):
		return
	actions.append({"a": "shop_remove", "i": deck_index})
	colony.stores -= int(shop.get("remove_cost", 0))
	colony.deck.remove_at(deck_index)


func shop_buy_card(offer_index: int) -> void:
	var cards: Array = shop.get("cards", [])
	if phase != PHASE_SHOP or offer_index < 0 or offer_index >= cards.size():
		return
	if colony.stores < int(shop.get("card_cost", 0)):
		return
	actions.append({"a": "shop_buy", "i": offer_index})
	colony.stores -= int(shop.get("card_cost", 0))
	colony.deck.append(CardLib.make(String(cards[offer_index])))


func shop_take_relic() -> void:
	if phase != PHASE_SHOP or String(shop.get("relic", "")) == "":
		return
	actions.append({"a": "shop_relic"})
	var rid := String(shop["relic"])
	if content.relics.has(rid):
		colony.relics.append(content.relics[rid])
	shop["relic"] = ""


func shop_leave() -> void:
	if phase != PHASE_SHOP:
		return
	actions.append({"a": "shop_leave"})
	_continue_after_node(false)


# --- Belohnung -------------------------------------------------------------


func choose_reward(index: int) -> void:
	if phase != PHASE_REWARD or engine == null:
		return
	var choices: Array = engine.enc.reward_choices
	if index < 0 or index >= choices.size():
		return
	actions.append({"a": "reward", "i": index})
	colony.deck.append(CardLib.make(String(choices[index])))
	_continue_after_node(_pending_boss)


func skip_reward() -> void:
	if phase != PHASE_REWARD:
		return
	actions.append({"a": "reward_skip"})
	_continue_after_node(_pending_boss)


# --- Zustand / Save / Replay ----------------------------------------------


func is_finished() -> bool:
	return finished


func snapshot() -> Dictionary:
	return {
		"act": act,
		"row": row,
		"phase": phase,
		"finished": finished,
		"wintering": wintering,
		"colony": colony.snapshot(),
		"encounter": engine.enc.snapshot() if engine != null else {},
	}


func to_save() -> Dictionary:
	return {"schemaVersion": 1, "seed": master_seed, "actions": actions.duplicate(true)}


static func from_save(
	data: Dictionary, content_db: ContentDB, config_dict: Dictionary
) -> RunController:
	var rc := RunController.new(int(data.get("seed", 0)), content_db, config_dict)
	for action: Dictionary in data.get("actions", []):
		rc._apply_action(action)
	return rc


# --- intern ----------------------------------------------------------------


func _start_deck() -> Array:
	var deck: Array = []
	for id: String in config.get("start_deck", []):
		deck.append(CardLib.make(id))
	return deck


func _begin_act(act_num: int) -> void:
	act = act_num
	row = -1
	map = RunMap.generate(rng, act_num, config)
	phase = PHASE_MAP


func _enter_node() -> void:
	var node_type := String(_node.get("type", ""))
	match node_type:
		"encounter", "boss":
			_start_encounter()
		"event":
			_start_event()
		"shop":
			_start_shop()
		_:
			_continue_after_node(false)


func _start_encounter() -> void:
	var tdef: Dictionary = content.threats.get(String(_node.get("threat_id", "")), {})
	var threat := ThreatState.from_def(tdef)
	var enc := EncounterState.from_colony(colony, threat)
	engine = TurnEngine.new(enc, rng, content, GameLog.new(), colony.relics)
	phase = PHASE_ENCOUNTER
	engine.start_encounter()
	_check_encounter_end()


func _check_encounter_end() -> void:
	if engine == null or not engine.is_over():
		return
	engine.enc.write_back(colony)
	_pending_boss = String(_node.get("type", "")) == "boss"
	if engine.enc.result == "won" and not engine.enc.reward_choices.is_empty():
		phase = PHASE_REWARD
	else:
		_continue_after_node(_pending_boss)


func _start_event() -> void:
	event = _pick_event()
	if event.is_empty():
		_continue_after_node(false)
		return
	phase = PHASE_EVENT


func _pick_event() -> Dictionary:
	var pool: Array = []
	for eid: String in content.events.keys():
		if _used_events.has(eid):
			continue
		if int(content.events[eid].get("act", 1)) <= act:
			pool.append(eid)
	if pool.is_empty():
		return {}
	pool.sort()
	var pick := String(pool[rng.randi_range("event", 0, pool.size() - 1)])
	_used_events[pick] = true
	return content.events[pick]


func _start_shop() -> void:
	var scfg: Dictionary = config.get("shop", {})
	var card_pool: Array = scfg.get("card_pool", []).duplicate()
	card_pool.sort()
	rng.shuffle("event", card_pool)
	var relic_pool: Array = []
	for rid: String in scfg.get("relic_pool", []):
		if not _owns_relic(rid):
			relic_pool.append(rid)
	relic_pool.sort()
	var relic := ""
	if not relic_pool.is_empty():
		relic = String(relic_pool[rng.randi_range("event", 0, relic_pool.size() - 1)])
	shop = {
		"cards": card_pool.slice(0, 3),
		"relic": relic,
		"card_cost": int(scfg.get("card_cost", 6)),
		"remove_cost": int(scfg.get("remove_cost", 0)),
	}
	phase = PHASE_SHOP


func _owns_relic(rid: String) -> bool:
	for relic: Dictionary in colony.relics:
		if String(relic.get("id", "")) == rid:
			return true
	return false


func _continue_after_node(was_boss: bool) -> void:
	engine = null
	event = {}
	shop = {}
	if not colony.is_alive():
		phase = PHASE_DEAD
		finished = true
		return
	if was_boss:
		if act < int(config.get("acts", 3)):
			_begin_act(act + 1)
		else:
			_do_wintering()
			phase = PHASE_WINTERING
			finished = true
	else:
		phase = PHASE_MAP


func _do_wintering() -> void:
	wintering = evaluate_wintering(
		colony.strength, colony.stores, colony.varroa, config.get("wintering", {})
	)


## Einwinterungs-Stufe aus Schwellen (rein, testbar). Hoechste erfuellte Stufe.
static func evaluate_wintering(strength: int, stores: int, varroa: int, w: Dictionary) -> String:
	var tier := "kein"
	for name: String in ["bronze", "silber", "gold"]:
		if not w.has(name):
			continue
		var t: Dictionary = w[name]
		if (
			strength >= int(t.get("strength", 0))
			and stores >= int(t.get("stores", 0))
			and varroa <= int(t.get("varroa_max", 0))
		):
			tier = name
	return tier


func _apply_colony_effects(effects: Array) -> void:
	for effect: Dictionary in effects:
		_apply_colony_effect(effect)


func _apply_colony_effect(effect: Dictionary) -> void:
	var op := String(effect.get("op", ""))
	var value := int(effect.get("value", 0))
	match op:
		"gain_stores":
			colony.stores += value
		"spend_stores":
			colony.stores = max(0, colony.stores - value)
		"heal":
			colony.strength += value
		"add_varroa":
			colony.varroa += value
		"reduce_varroa":
			colony.varroa = max(0, colony.varroa - value)
		"generate_card":
			var cid := String(effect.get("card_id", ""))
			if cid != "":
				colony.deck.append(CardLib.make(cid))
		"convert":
			_apply_convert(effect)
		_:
			pass


func _apply_convert(effect: Dictionary) -> void:
	var from := String(effect.get("from", ""))
	var to := String(effect.get("to", ""))
	var ratio: int = max(1, int(effect.get("ratio", 1)))
	var amount := _colony_res(from)
	_colony_res_set(from, 0)
	_colony_res_add(to, amount / ratio)


func _colony_res(name: String) -> int:
	match name:
		"strength":
			return colony.strength
		"stores":
			return colony.stores
		"varroa":
			return colony.varroa
	return 0


func _colony_res_set(name: String, val: int) -> void:
	match name:
		"strength":
			colony.strength = max(0, val)
		"stores":
			colony.stores = max(0, val)
		"varroa":
			colony.varroa = max(0, val)


func _colony_res_add(name: String, delta: int) -> void:
	_colony_res_set(name, _colony_res(name) + delta)


func _apply_action(action: Dictionary) -> void:
	var a := String(action.get("a", ""))
	var i := int(action.get("i", 0))
	match a:
		"node":
			choose_node(i)
		"play":
			play_card(i)
		"end":
			end_turn()
		"event":
			choose_event_option(i)
		"shop_remove":
			shop_remove_card(i)
		"shop_buy":
			shop_buy_card(i)
		"shop_relic":
			shop_take_relic()
		"shop_leave":
			shop_leave()
		"reward":
			choose_reward(i)
		"reward_skip":
			skip_reward()
