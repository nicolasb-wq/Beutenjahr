extends TestCase
## Block 1: i18n-Service (Loc) — Lookup, Locale-Wechsel, Fallback.


func before_each() -> void:
	Loc.set_locale("de")


func after_each() -> void:
	Loc.set_locale("de")


func test_lookup_de() -> void:
	Loc.set_locale("de")
	assert_eq(Loc.t("ui.greybox.end_turn"), "Zug beenden")


func test_lookup_en() -> void:
	Loc.set_locale("en")
	assert_eq(Loc.t("ui.greybox.end_turn"), "End turn")


func test_fallback_to_key() -> void:
	assert_eq(Loc.t("does.not.exist"), "does.not.exist")


func test_locale_switch_changes_output() -> void:
	Loc.set_locale("de")
	var de := Loc.t("card.sammelflug.name")
	Loc.set_locale("en")
	var en := Loc.t("card.sammelflug.name")
	assert_ne(de, en, "Sprachwechsel ändert Ausgabe")
	assert_eq(de, "Sammelflug")
	assert_eq(en, "Foraging flight")


func test_result_keys_present() -> void:
	for key: String in ["ui.result.won", "ui.result.lost", "ui.result.fled", "ui.result.open"]:
		assert_true(Loc.has_key(key), "Ergebnis-Key vorhanden: " + key)


func test_available_locales() -> void:
	assert_eq(Loc.available_locales(), ["de", "en"])
