extends Control
## Greybox-Minimal-UI (Block 2): spielt einen GANZEN Run ueber den RunController —
## Pfadwahl, Begegnung, Ereignis, Imkerbesuch, Belohnung, Einwinterung. Reiner
## Konsument des headless Kerns; alle Texte ueber Loc (kein hartkodierter
## Anzeigetext). "null Schoenheit, volle Funktion" — Optik folgt in Block 4.

const CONFIG_PATH: String = "res://content/config/run.json"

var _content: ContentDB
var _config: Dictionary
var _rc: RunController
var _seed_counter: int = 1000

var _title_label: Label
var _act_label: Label
var _colony_label: Label
var _lang_button: Button
var _new_run_button: Button
var _content_box: VBoxContainer


func _ready() -> void:
	_content = ContentDB.new()
	_content.load_all()
	_config = JSON.parse_string(FileAccess.get_file_as_string(CONFIG_PATH))
	Loc.set_locale(Loc.DEFAULT_LOCALE)
	_build_chrome()
	_start_run()


func _build_chrome() -> void:
	var root := VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", 10)
	add_child(root)
	_title_label = _label(root)
	_act_label = _label(root)
	_colony_label = _label(root)
	var bar := HBoxContainer.new()
	bar.add_theme_constant_override("separation", 8)
	root.add_child(bar)
	_lang_button = _button(bar, _on_switch_lang)
	_new_run_button = _button(bar, _start_run)
	_content_box = VBoxContainer.new()
	_content_box.add_theme_constant_override("separation", 6)
	root.add_child(_content_box)


func _label(parent: Node) -> Label:
	var lbl := Label.new()
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	parent.add_child(lbl)
	return lbl


func _button(parent: Node, cb: Callable) -> Button:
	var btn := Button.new()
	btn.pressed.connect(cb)
	parent.add_child(btn)
	return btn


func _start_run() -> void:
	_seed_counter += 1
	_rc = RunController.new(_seed_counter, _content, _config)
	_refresh()


func _on_switch_lang() -> void:
	Loc.set_locale("en" if Loc.get_locale() == "de" else "de")
	_refresh()


func _refresh() -> void:
	_title_label.text = Loc.t("ui.greybox.title")
	var season := _rc.map.season if _rc.map != null else ""
	_act_label.text = Loc.t("ui.greybox.act") % [_rc.act, _season_label(season)]
	var c := _rc.colony
	_colony_label.text = (
		Loc.t("ui.greybox.colony")
		% [c.strength, c.stores, c.varroa, Balance.varroa_pressure(c.varroa)]
	)
	_lang_button.text = Loc.t("ui.greybox.switch_lang")
	_new_run_button.text = Loc.t("ui.greybox.new_run")
	for child in _content_box.get_children():
		child.queue_free()
	match _rc.phase:
		"map":
			_build_map()
		"encounter":
			_build_encounter()
		"event":
			_build_event()
		"shop":
			_build_shop()
		"reward":
			_build_reward()
		_:
			_build_end()


# --- Phasen-Ansichten ------------------------------------------------------


func _build_map() -> void:
	_label(_content_box).text = Loc.t("ui.greybox.choose_path")
	var nodes := _rc.available_nodes()
	for i in nodes.size():
		var btn := _button(_content_box, _on_choose_node.bind(i))
		btn.text = _node_label(String(nodes[i]["type"]))


func _build_encounter() -> void:
	var enc := _rc.engine.enc
	var threat := enc.threat
	_label(_content_box).text = (
		(Loc.t("ui.greybox.threat") % Loc.t(String(threat.def.get("name_key", threat.id))))
		+ "   "
		+ (Loc.t("ui.greybox.hp") % [threat.hp, threat.max_hp])
	)
	_label(_content_box).text = Loc.t("ui.greybox.intent") % _intent_name(threat)
	_label(_content_box).text = _enc_state_line(enc)
	for i in enc.hand.size():
		var card: Dictionary = enc.hand[i]
		var def: Dictionary = _content.cards.get(String(card.get("id", "")), {})
		var btn := _button(_content_box, _on_play.bind(i))
		btn.text = (
			"%s (%d)"
			% [_card_name(def, card), CardLib.cost(def, bool(card.get("upgraded", false)))]
		)
		btn.disabled = not _rc.engine.can_play(i)
	_button(_content_box, _on_end_turn).text = Loc.t("ui.greybox.end_turn")


func _build_event() -> void:
	_label(_content_box).text = (
		Loc.t("ui.event.title") % Loc.t(String(_rc.event.get("name_key", "")))
	)
	_label(_content_box).text = Loc.t(String(_rc.event.get("text_key", "")))
	var options: Array = _rc.event.get("options", [])
	for i in options.size():
		var btn := _button(_content_box, _on_event_option.bind(i))
		btn.text = Loc.t(String(options[i].get("label_key", "")))


func _build_shop() -> void:
	_label(_content_box).text = Loc.t("ui.shop.title") % _rc.colony.stores
	var cost := int(_rc.shop.get("card_cost", 6))
	var cards: Array = _rc.shop.get("cards", [])
	for i in cards.size():
		var def: Dictionary = _content.cards.get(String(cards[i]), {})
		var btn := _button(_content_box, _on_shop_buy.bind(i))
		btn.text = Loc.t("ui.shop.buy") % [_card_name(def, {"id": cards[i]}), cost]
		btn.disabled = _rc.colony.stores < cost
	if String(_rc.shop.get("relic", "")) != "":
		var rdef: Dictionary = _content.relics.get(String(_rc.shop["relic"]), {})
		var name_key := String(rdef.get("name_key", String(_rc.shop["relic"])))
		_button(_content_box, _on_shop_relic).text = Loc.t("ui.shop.relic") % Loc.t(name_key)
	for i in _rc.colony.deck.size():
		var card: Dictionary = _rc.colony.deck[i]
		var def: Dictionary = _content.cards.get(String(card.get("id", "")), {})
		_button(_content_box, _on_shop_remove.bind(i)).text = (
			Loc.t("ui.shop.remove") % _card_name(def, card)
		)
	_button(_content_box, _on_shop_leave).text = Loc.t("ui.shop.leave")


func _build_reward() -> void:
	_label(_content_box).text = Loc.t("ui.reward.title")
	var choices: Array = _rc.engine.enc.reward_choices
	for i in choices.size():
		var def: Dictionary = _content.cards.get(String(choices[i]), {})
		_button(_content_box, _on_reward.bind(i)).text = _card_name(def, {"id": choices[i]})
	_button(_content_box, _on_reward_skip).text = Loc.t("ui.reward.skip")


func _build_end() -> void:
	if _rc.phase == "dead":
		_label(_content_box).text = Loc.t("ui.greybox.dead")
	else:
		_label(_content_box).text = Loc.t("ui.wintering.title") % _wintering_label(_rc.wintering)


# --- Eingabe-Handler -------------------------------------------------------


func _on_choose_node(index: int) -> void:
	_rc.choose_node(index)
	_refresh()


func _on_play(index: int) -> void:
	_rc.play_card(index)
	_refresh()


func _on_end_turn() -> void:
	_rc.end_turn()
	_refresh()


func _on_event_option(index: int) -> void:
	_rc.choose_event_option(index)
	_refresh()


func _on_shop_buy(index: int) -> void:
	_rc.shop_buy_card(index)
	_refresh()


func _on_shop_remove(index: int) -> void:
	_rc.shop_remove_card(index)
	_refresh()


func _on_shop_relic() -> void:
	_rc.shop_take_relic()
	_refresh()


func _on_shop_leave() -> void:
	_rc.shop_leave()
	_refresh()


func _on_reward(index: int) -> void:
	_rc.choose_reward(index)
	_refresh()


func _on_reward_skip() -> void:
	_rc.skip_reward()
	_refresh()


# --- Helfer ----------------------------------------------------------------


func _card_name(def: Dictionary, card: Dictionary) -> String:
	var name_key := String(def.get("name_key", ""))
	return Loc.t(name_key) if name_key != "" else String(card.get("id", "?"))


func _intent_name(threat: ThreatState) -> String:
	var intent := threat.current_intent
	if intent.is_empty():
		return "-"
	return Loc.t(String(intent.get("name_key", intent.get("id", "-"))))


func _enc_state_line(enc: EncounterState) -> String:
	return (
		"%s %d | %s %d | %s %d (%s %d) | %s %d/%d | %s %d | %s %d"
		% [
			Loc.t("ui.state.strength"),
			enc.strength,
			Loc.t("ui.state.stores"),
			enc.stores,
			Loc.t("ui.state.varroa"),
			enc.varroa,
			Loc.t("ui.state.pressure"),
			Balance.varroa_pressure(enc.varroa),
			Loc.t("ui.state.energy"),
			enc.energy,
			enc.max_energy,
			Loc.t("ui.state.guards"),
			enc.guards,
			Loc.t("ui.state.turn"),
			enc.turn_number,
		]
	)


func _node_label(node_type: String) -> String:
	match node_type:
		"encounter":
			return Loc.t("ui.node.encounter")
		"event":
			return Loc.t("ui.node.event")
		"shop":
			return Loc.t("ui.node.shop")
		"boss":
			return Loc.t("ui.node.boss")
		_:
			return node_type


func _season_label(season: String) -> String:
	match season:
		"fruehjahr":
			return Loc.t("ui.season.fruehjahr")
		"fruehsommer":
			return Loc.t("ui.season.fruehsommer")
		"spaetsommer":
			return Loc.t("ui.season.spaetsommer")
		_:
			return season


func _wintering_label(tier: String) -> String:
	match tier:
		"bronze":
			return Loc.t("ui.wintering.bronze")
		"silber":
			return Loc.t("ui.wintering.silber")
		"gold":
			return Loc.t("ui.wintering.gold")
		_:
			return Loc.t("ui.wintering.kein")
