# Block 1 — Lokalisierung (Akzeptanzkriterien)

- **Datum:** 2026-09-07 · **Status:** ✅ abgeschlossen (CI grün, Commit a158794)
- **LOOP-Bezug:** Block 1 (Vorbedingung, vor allen Texten). Ab Blockende: **kein neuer Text ohne Key in beiden Sprachen.**

## Vorprüfung (LOOP §5 Block 1)
- Lokalisierung ist vorgesehen: **Serien-Handbuch §1.7** („DE/EN über Keys ab Tag 1") und **Blueprint AP 5.2** („Lokalisierung DE/EN über Keys von Tag 1"). **Keine Blueprint-Abweichung nötig.**

## Scope-Grenze (bewusst, dokumentiert)
- **Player-facing Text** wird lokalisiert: UI-Chrome (Greybox), Content-Namen/-Texte (Karten/Bedrohungen/Ereignisse), Intent-Anzeigenamen.
- **Nicht** lokalisiert: `core/GameLog`-Zeilen (Entwickler-Diagnose, kein finales UI — wird in Phase 5 durch echtes UI-Feedback ersetzt) und `kompendium_key` (Kompendium-Inhalt ist Phase-5-Deliverable mit Fach-Review R4). Beides ist als Ausnahme hier festgehalten, kein stiller Skip.

## Akzeptanzkriterien

- [ ] **K1 — i18n-System vorhanden.** `Loc` (headless, ohne Node) lädt `assets/i18n/de.json` und `en.json`, bietet `t(key)`, `set_locale(code)`, `get_locale()`, Fallback auf Key bei fehlender Übersetzung; registriert die Sprachen zusätzlich beim `TranslationServer` (damit `tr()` künftig funktioniert).
- [ ] **K2 — Alle vorhandenen player-facing Texte als Keys.** Jede `name_key`/`text_key` (Karten, Bedrohungen), jede Ereignis-`text_key` und Options-`label_key`, sowie ein Anzeige-`name_key` je Bedrohungs-Intent existieren als Schlüssel. Die Greybox nutzt Keys statt hartkodierter Strings.
- [ ] **K3 — DE und EN vollständig gepflegt.** `de.json` und `en.json` haben **identische Schlüsselmengen**; kein Wert ist leer.
- [ ] **K4 — Sprachumschaltung im Spiel.** Die Greybox hat einen DE/EN-Umschalter, der Chrome **und** Content-Anzeige live wechselt (kein Neustart nötig).
- [ ] **K5 — Maschinelle Vollständigkeits-Prüfung in CI.** `tools/validate_i18n.py` prüft: (a) de/en-Schlüsselparität, keine Leerwerte; (b) jeder in Content referenzierte `name_key`/`text_key`/`label_key`/Intent-`name_key` existiert in beiden Sprachen; (c) jeder von der UI benötigte Key existiert. Läuft im Lint-Job (ohne Godot).
- [ ] **K6 — Headless-Tests grün.** `tests/test_loc.gd`: Lookup, Locale-Wechsel, Fallback, Parität. In CI.
- [ ] **K7 — CI grün (beide Jobs).** Lint + i18n-Validierung + Content-Validierung + Godot-Import + alle Headless-Tests.

## Abnahme (abgehakt, 2026-09-07)

- [x] **K1** — `core/loc.gd` (t/set_locale/get_locale/has_key, Fallback, TranslationServer). `test_loc` grün.
- [x] **K2** — Alle player-facing Keys: Content (name/text/label), Intent-`name_key` (Schema + 4 Bedrohungen), Greybox nutzt ausschließlich `Loc.t`.
- [x] **K3** — `assets/i18n/{de,en}.json`: 79 Keys, identische Mengen, keine Leerwerte (Validator).
- [x] **K4** — Sprachumschalter live (`Greybox._on_switch_lang`); `test_greybox_language_switch` bestätigt Wechsel von Chrome **und** Content-Anzeige.
- [x] **K5** — `tools/validate_i18n.py` in CI (Lint-Job, Schritt „Lokalisierung validieren"); Negativtest bestätigte Greifen (Parität/Leerwert/fehlender Key).
- [x] **K6** — `tests/test_loc.gd` (6 Tests) grün.
- [x] **K7** — CI beide Jobs grün, **ALLE 67 TESTS GRUEN** (Runs ca5a34a/a158794).

Keine Nachbesserungsrunde nötig (0/5 verbraucht). **Blueprint-Abweichung: keine.**
