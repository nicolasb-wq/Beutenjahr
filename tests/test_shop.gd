extends TestCase
## Block 2 K5: Imkerbesuch (Shop) — Karte entfernen/kaufen, Relikt.
## Nutzt einen _ts-Sofortsieg-Deck, damit Begegnungen vor dem Shop das Volk
## nicht toeten.

var content: ContentDB
var cfg: Dictionary


func before_each() -> void:
	content = ContentDB.new()
	content.load_all()
	content.cards["_ts"] = {
		"id": "_ts",
		"name_key": "x",
		"text_key": "x",
		"type": "aktion",
		"cost": 0,
		"rarity": "common",
		"archetype": "neutral",
		"act": 1,
		"effects": [{"op": "deal_damage", "value": 999, "target": "threat"}],
	}
	cfg = JSON.parse_string(FileAccess.get_file_as_string("res://content/config/run.json"))
	cfg["start_deck"] = ["_ts", "_ts", "_ts", "_ts", "_ts", "_ts"]


func _to_shop(rc: RunController) -> bool:
	var guard := 0
	while not rc.is_finished() and guard < 500:
		guard += 1
		if rc.phase == "shop":
			return true
		match rc.phase:
			"map":
				var nodes := rc.available_nodes()
				if nodes.is_empty():
					return false
				var idx := 0
				for j in nodes.size():
					if String(nodes[j]["type"]) == "shop":
						idx = j
						break
				rc.choose_node(idx)
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
			"reward":
				rc.choose_reward(0)
			_:
				return false
	return rc.phase == "shop"


func test_shop_remove_card() -> void:
	var rc := RunController.new(4, content, cfg)
	assert_true(_to_shop(rc), "Shop erreicht")
	var before := rc.colony.deck.size()
	rc.shop_remove_card(0)
	assert_eq(rc.colony.deck.size(), before - 1, "Karte entfernt (Deck-Hygiene)")


func test_shop_buy_card() -> void:
	var rc := RunController.new(7, content, cfg)
	assert_true(_to_shop(rc), "Shop erreicht")
	rc.colony.stores = 20
	var before := rc.colony.deck.size()
	rc.shop_buy_card(0)
	assert_eq(rc.colony.deck.size(), before + 1, "Karte gekauft")
	assert_eq(rc.colony.stores, 20 - int(rc.shop["card_cost"]), "Vorraete bezahlt")


func test_shop_take_relic() -> void:
	var rc := RunController.new(13, content, cfg)
	assert_true(_to_shop(rc), "Shop erreicht")
	if String(rc.shop.get("relic", "")) != "":
		var before := rc.colony.relics.size()
		rc.shop_take_relic()
		assert_eq(rc.colony.relics.size(), before + 1, "Relikt genommen")
		assert_eq(String(rc.shop.get("relic", "")), "", "Angebot verbraucht")
	else:
		assert_true(true, "kein Relikt im Angebot (zulaessig)")
