extends Control
## Greybox-Minimal-UI fuer das SPASS-GATE (Blueprint AP 2.2): "null Schoenheit,
## volle Funktion". Die UI ist reiner Konsument des headless Kerns (core/) —
## keine Spielregeln hier, nur Anzeige + Eingabe.
##
## Bewusst programmatisch aufgebaut (keine handgepflegte .tscn-Knotenwand).
## Die finale, gestaltete UI entsteht in Phase 5.

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

var _threat_label: Label
var _intent_label: Label
var _state_label: Label
var _result_label: Label
var _log_label: Label
var _hand_box: HBoxContainer
var _end_button: Button


func _ready() -> void:
	_content = ContentDB.new()
	_content.load_all()
	_build_ui()
	_new_encounter()


func _build_ui() -> void:
	var vbox := VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 12)
	add_child(vbox)

	var title := Label.new()
	title.text = "Beutenjahr — Greybox (Akt 1)"
	vbox.add_child(title)

	_threat_label = _mk_label(vbox)
	_intent_label = _mk_label(vbox)
	_state_label = _mk_label(vbox)

	var restart := Button.new()
	restart.text = "Neuer Run"
	restart.pressed.connect(_new_encounter)
	vbox.add_child(restart)

	_end_button = Button.new()
	_end_button.text = "Zug beenden"
	_end_button.pressed.connect(_on_end_turn)
	vbox.add_child(_end_button)

	var hand_title := Label.new()
	hand_title.text = "Hand (antippen zum Spielen):"
	vbox.add_child(hand_title)

	_hand_box = HBoxContainer.new()
	_hand_box.add_theme_constant_override("separation", 8)
	vbox.add_child(_hand_box)

	_result_label = _mk_label(vbox)
	_log_label = _mk_label(vbox)
	_log_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART


func _mk_label(parent: Node) -> Label:
	var lbl := Label.new()
	parent.add_child(lbl)
	return lbl


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
	_threat_label.text = "Bedrohung: %s   HP %d/%d" % [threat.id, threat.hp, threat.max_hp]
	_intent_label.text = "Kuendigt an: %s" % String(threat.current_intent.get("id", "-"))
	var pressure := Balance.varroa_pressure(enc.varroa)
	_state_label.text = (
		"Staerke %d | Vorrat %d | Varroa %d (Druck %d) | Energie %d/%d | Waechter %d | Zug %d"
		% [
			enc.strength,
			enc.stores,
			enc.varroa,
			pressure,
			enc.energy,
			enc.max_energy,
			enc.guards,
			enc.turn_number,
		]
	)
	_rebuild_hand()
	_end_button.disabled = _engine.is_over()
	if _engine.is_over():
		_result_label.text = "Ergebnis: %s    Belohnung: %s" % [enc.result, str(enc.reward_choices)]
	else:
		_result_label.text = ""
	_log_label.text = _tail_log()


func _rebuild_hand() -> void:
	for child in _hand_box.get_children():
		child.queue_free()
	for i in _engine.enc.hand.size():
		var card: Dictionary = _engine.enc.hand[i]
		var def: Dictionary = _content.cards.get(String(card.get("id", "")), {})
		var btn := Button.new()
		var cost := CardLib.cost(def, bool(card.get("upgraded", false)))
		btn.text = "%s (%d)" % [String(card.get("id", "?")), cost]
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
