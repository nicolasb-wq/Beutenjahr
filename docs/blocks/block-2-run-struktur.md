# Block 2 — Phase 3: Run-Struktur (Akzeptanzkriterien)

- **Datum:** 2026-09-07 · **Status:** ✅ abgeschlossen (CI grün, Commit 1220099, 83 Tests)
- **LOOP-Bezug:** Block 2 → **STOPP 1** (Prüffrage: „Trägt der Kern-Loop über einen ganzen Run?").
- **Blueprint:** Phase 3 (AP 3.1 Pfadkarte/Akt-Fluss/Einwinterung, AP 3.2 Ereignisse/Tausch/Relikte, AP 3.3 Meta-Save/Freischaltbaum/Replay).

## Architektur-Notiz (Voraussetzung)
Ein Run braucht **persistenten Volkszustand** über Begegnungen hinweg: `ColonyState`
(Volksstärke, Vorräte, Varroa, Deck, Relikte, max. Energie). Jede Begegnung wird aus
dem `ColonyState` initialisiert und schreibt Volksstärke/Vorräte/Varroa am Ende zurück.
Der `RunController` orchestriert Akte, Knoten und Einwinterung. Run-Parameter
(Aktzahl, Knoten/Reihen, Einwinterungs-Schwellen, Akt-Bedrohungen/-Bosse, Jahreszeiten)
liegen in `content/config/run.json`.

## Scope-Grenze (bewusst, dokumentiert)
- Knotentypen v1: `encounter`, `event`, `shop` (Imkerbesuch), `boss`. **`Standortwechsel`
  (Stadt/Land/Berg) ist im Blueprint „Später" (Akt-Varianten)** → nicht in v1, in `docs/adr/` vermerkt.
- Die Pfadkarten-**Grafik** ist Phase 5; Block 2 liefert eine funktionale, tap-bedienbare
  (Listen-)Auswahl in der Greybox. Aussehen bleibt Nicos Debug-Build-Prüfung (STOPP 1).

## Akzeptanzkriterien

- [ ] **K1 — Knoten-Graph (AP 3.1).** Seeded Generator (`map`-Strom) erzeugt je Akt einen Graphen (~12 Knoten, 5–6 Reihen) mit regelbasiertem Typen-Mix. Garantien: genau **1 Boss** als Aktabschluss, **≥1 Shop** je Akt, jede Reihe erreichbar (gültige Kanten). Determinismus: gleicher Seed → identischer Graph. Getestet.
- [ ] **K2 — Run-Fluss (AP 3.1).** `RunController` spielt einen **kompletten Run über 3 Akte** headless: pro Akt Pfadwahl über den Graphen; Knoten `encounter/event/shop/boss` werden aufgelöst; Aktwechsel funktionieren; `ColonyState` persistiert (Volksstärke/Vorräte/Varroa/Deck) zwischen Begegnungen. Getestet.
- [ ] **K3 — Einwinterungs-Bewertung (AP 3.1).** Nach Akt 3 werden Volksstärke/Vorräte/Varroa gegen Schwellen aus `run.json` bewertet → `kein`/`bronze`/`silber`/`gold`. Grenzfälle getestet.
- [ ] **K4 — Belohnung wirkt.** Nach gewonnener Begegnung wird eine gewählte Karte aus `reward_choices` ins Run-Deck übernommen (Deck wächst). Getestet.
- [ ] **K5 — Ereignisse & Imkerbesuch-Tausch (AP 3.2).** Ereignis-Knoten bieten Optionen (persistente Effekte). Shop: **Karte entfernen** (Deck-Hygiene!), Karte gegen Vorräte kaufen, Relikt-Angebot. Seeded, getestet.
- [ ] **K6 — Meta-Save + Run-Autosave (AP 3.3).** Atomar (Temp-Datei + Rename), `schemaVersion` ab Save 1. Run übersteht „App-Kill": Speichern/Laden mitten im Run reproduziert den Zustand (Roundtrip-Test).
- [ ] **K7 — Replay (AP 3.3).** Seed + Aktionsliste exportier-/importierbar; Replay reproduziert einen kompletten Run **bitidentisch** (Snapshot-Vergleich). Getestet.
- [ ] **K8 — Greybox spielt einen ganzen Run.** Akt 1→3 + Einwinterung, tap-bedienbar, **vollständig lokalisiert** (Block-1-Regel: neue Texte = Keys in DE+EN). Off-tree-Smoke-Test.
- [ ] **K9 — CI grün (beide Jobs).** Lint, Variant-Wächter, Content-, i18n-Validierung, Godot-Import, alle Headless-Tests.

## Lauffähiges Ergebnis
Ein **spielbarer Build eines ganzen Runs** (Akt 1 bis Einwinterung) → **STOPP 1**: Nico spielt, prüft „Trägt der Kern-Loop?".

## Abnahme (abgehakt, 2026-09-07)

- [x] **K1** — `core/run_map.gd` seeded; `test_run_map`: Determinismus, Boss letzte Reihe, ≥1 Shop/Akt, Reihenzahl, verschiedene Akt-Bosse.
- [x] **K2** — `core/run_controller.gd` spielt 3 Akte über den Graphen; `test_run.test_full_run_finishes` + `test_run_deterministic`. `ColonyState` persistiert.
- [x] **K3** — `RunController.evaluate_wintering`; `test_run.test_wintering_thresholds` (gold/silber/bronze/kein + Varroa-Kipp).
- [x] **K4** — Belohnung ins Deck; `test_run.test_reward_grows_deck`.
- [x] **K5** — Ereignisse (`choose_event_option`) + Imkerbesuch; `test_shop` (entfernen/kaufen/Relikt).
- [x] **K6** — `core/save_service.gd` atomar (Temp+Rename), `schemaVersion`; `test_save` (Datei-Roundtrip, keine .tmp-Leiche).
- [x] **K7** — Replay `from_save` (Seed+Aktionen); `test_save.test_replay_bitidentical`.
- [x] **K8** — `ui/Greybox.gd` spielt einen ganzen Run (lokalisiert); `test_greybox_ui.test_greybox_full_run_smoke` + Sprachwechsel.
- [x] **K9** — CI beide Jobs grün, **ALLE 83 TESTS GRUEN** (Run 1220099).

0/5 Nachbesserungsrunden. **Blueprint-Abweichung:** Standortwechsel-Knoten später (ADR-0005).

**Lauffähiges Ergebnis:** ein ganzer Run (Akt 1→3 + Einwinterung) ist spielbar → **STOPP 1** (`docs/stops/stopp-1.md`).
