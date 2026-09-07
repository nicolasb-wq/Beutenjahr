extends Control
## Greybox-Minimal-UI fuer das SPASS-GATE (Blueprint AP 2.2): "null Schoenheit,
## volle Funktion". Reiner Konsument des headless Kerns (core/) — keine
## Spielregeln hier, nur Anzeige + Eingabe. Alle Texte ueber Loc (Block 1):
## kein hartkodierter Anzeigetext. Die finale, gestaltete UI entsteht in Phase 5.

const START_DECK: Array = [
	"pollen_sammeln",
	"pollen_sammeln",
	"sammelflug",
	"sammelflug",
	"stich_abwehr",
	"stich_abwehr",
	"waechterinnen",
	"raeuchern",
	"schwaenzeltanz",
	"auffuettern",
]
const START_THREAT: String = "wespe_einzeln"

var _content: ContentDB
var _run: RunState
var _engine: TurnEngine
var _run_counter: int = 0

var _title_label: Label
var _hand_title_label: Label
var _threat_label: Label
var _intent_label: Label
var _state_label: Label
var _result_label: Label
var _log_label: Label
var _hand_box: HBoxContainer
var _end_button: Button
var _new_run_button: Button
var _lang_button: Button


func _ready() -> void:
	_content = ContentDB.new()
	_content.load_all()
	Loc.set_locale(Loc.DEFAULT_LOCALE)
	_build_ui()
	_new_encounter()


func _build_ui() -> void:
	var vbox := VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 12)
	add_child(vbox)

	_title_label = _mk_label(vbox)
	_threat_label = _mk_label(vbox)
	_intent_label = _mk_label(vbox)
	_state_label = _mk_label(vbox)

	_lang_button = Button.new()
	_lang_button.pressed.connect(_on_switch_lang)
	vbox.add_child(_lang_button)

	_new_run_button = Button.new()
	_new_run_button.pressed.connect(_new_encounter)
	vbox.add_child(_new_run_button)

	_end_button = Button.new()
	_end_button.pressed.connect(_on_end_turn)
	vbox.add_child(_end_button)

	_hand_title_label = _mk_label(vbox)

	_hand_box = HBoxContainer.new()
	_hand_box.add_theme_constant_override("separation", 8)
	vbox.add_child(_hand_box)

	_result_label = _mk_label(vbox)
	_log_label = _mk_label(vbox)
	_log_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_apply_chrome_texts()


func _mk_label(parent: Node) -> Label:
	var lbl := Label.new()
	parent.add_child(lbl)
	return lbl


func _apply_chrome_texts() -> void:
	_title_label.text = Loc.t("ui.greybox.title")
	_hand_title_label.text = Loc.t("ui.greybox.hand")
	_lang_button.text = Loc.t("ui.greybox.switch_lang")
	_new_run_button.text = Loc.t("ui.greybox.new_run")
	_end_button.text = Loc.t("ui.greybox.end_turn")


func _on_switch_lang() -> void:
	Loc.set_locale("en" if Loc.get_locale() == "de" else "de")
	_apply_chrome_texts()
	_refresh()


func _new_encounter() -> void:
	_run_counter += 1
	_run = RunState.new(1000 + _run_counter, _content)
	var deck: Array = []
	for id: String in START_DECK:
		deck.append(CardLib.make(id))
	_engine = _run.new_engine(_run.build_encounter(deck, START_THREAT), [])
	_engine.start_encounter()
	_refresh()


func _on_play(index: int) -> void:
	if _engine.is_over():
		return
	_engine.play_card(index)
	_refresh()


func _on_end_turn() -> void:
	if _engine.is_over():
		return
	_engine.end_turn()
	_refresh()


func _refresh() -> void:
	var enc := _engine.enc
	var threat := enc.threat
	var threat_name := Loc.t(String(threat.def.get("name_key", threat.id)))
	_threat_label.text = (
		(Loc.t("ui.greybox.threat") % threat_name)
		+ "   "
		+ (Loc.t("ui.greybox.hp") % [threat.hp, threat.max_hp])
	)
	_intent_label.text = Loc.t("ui.greybox.intent") % _intent_name(threat)
	_state_label.text = _state_line(enc)
	_rebuild_hand()
	_end_button.disabled = _engine.is_over()
	if _engine.is_over():
		_result_label.text = (
			(Loc.t("ui.greybox.result") % _result_text(enc.result))
			+ "    "
			+ (Loc.t("ui.greybox.reward") % str(enc.reward_choices))
		)
	else:
		_result_label.text = ""
	_log_label.text = _tail_log()


func _result_text(result: String) -> String:
	match result:
		"won":
			return Loc.t("ui.result.won")
		"lost":
			return Loc.t("ui.result.lost")
		"fled":
			return Loc.t("ui.result.fled")
		_:
			return Loc.t("ui.result.open")


func _intent_name(threat: ThreatState) -> String:
	var intent := threat.current_intent
	if intent.is_empty():
		return "-"
	return Loc.t(String(intent.get("name_key", intent.get("id", "-"))))


func _state_line(enc: EncounterState) -> String:
	var pressure := Balance.varroa_pressure(enc.varroa)
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
			pressure,
			Loc.t("ui.state.energy"),
			enc.energy,
			enc.max_energy,
			Loc.t("ui.state.guards"),
			enc.guards,
			Loc.t("ui.state.turn"),
			enc.turn_number,
		]
	)


func _rebuild_hand() -> void:
	for child in _hand_box.get_children():
		child.queue_free()
	for i in _engine.enc.hand.size():
		var card: Dictionary = _engine.enc.hand[i]
		var def: Dictionary = _content.cards.get(String(card.get("id", "")), {})
		var name_key := String(def.get("name_key", ""))
		var cname := Loc.t(name_key) if name_key != "" else String(card.get("id", "?"))
		var btn := Button.new()
		btn.text = "%s (%d)" % [cname, CardLib.cost(def, bool(card.get("upgraded", false)))]
		btn.disabled = _engine.is_over() or not _engine.can_play(i)
		btn.pressed.connect(_on_play.bind(i))
		_hand_box.add_child(btn)


func _tail_log() -> String:
	var lines := _engine.game_log.lines
	var start: int = max(0, lines.size() - 6)
	var out: Array = []
	for i in range(start, lines.size()):
		out.append(lines[i])
	return "\n".join(out)
