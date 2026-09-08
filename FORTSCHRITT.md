# FORTSCHRITT

Chronologisches Log. Neueste Einträge oben. Nach jeder Phase Checkliste abhaken.

---

## 2026-09-08 — STOPP 1 (feedback-unabhängige Arbeit)

Nico spielt den Debug-Build (Prüffrage „Trägt der Kern-Loop?"). Block 3 wird
bewusst NICHT gezogen. Der Loop arbeitet nur an nachweislich feedback-unabhängigen
Teilen (LOOP §4): Tests/Doku/Tooling.

### Erledigt
- **Test-Härtung Signaturmechanik** — neue Suite `tests/test_varroa_pressure.gd`
  (10 Tests). Verriegelt `Balance.varroa_pressure` an allen Schwellen **[8,14,20]**
  inkl. der Unterseiten 7/13/19 (Off-by-One-Schutz) und Deckelung bei 3;
  `_colony_out`-Boden-bei-Null; Milbendruck auf `deal_damage`→Bedrohung und `heal`;
  Behandlung (`reduce_varroa`/`dampen_varroa`) wird nie gesenkt; eingehender
  Bedrohungsschaden ignoriert die eigene Varroa.
  **Keine Balance-Zahlen und kein Block-3-Content geändert** — reine Absicherung
  bestehenden Verhaltens.
- **CI: beide Jobs grün, Commit fc6049d — ALLE 93 TESTS GRUEN** (zuvor 83).

### Offen / als Nächstes
- Weiter auf Nicos Spiel-Urteil warten (`docs/stops/stopp-1.md`). Bei „Go" → Block 3
  (Balancing & Vollcontent), Kriterien zuerst.

---

## 2026-07-21 — Phase 0 gestartet (Setup & Fundament)

### Erledigt
- **AP 0.1 (Marktcheck & Namensprüfung)** ✅ — `docs/marktcheck.md`, `docs/positionierung.md`.
  - R3: kein Bienen-Deckbuilder-Roguelite gefunden; Marktlücke hält vorläufig.
  - R6: keine Web-Kollision für „Beutenjahr"; DPMA/Store-Prüfung bleibt Mensch-Schritt.
- **AP 0.2 (Werkzeuge, Repo, ADR)** teilweise ✅ — Projektskelett, `project.godot`, Verzeichnisstruktur, `.gitignore`/`.gitattributes`, Platzhalter-`Main.tscn`, ADR-0000 + ADR-0001.
  - **Offen an AP 0.2:** realer Android-Export auf ein Handy — nicht in dieser Cloud-Umgebung möglich → `MENSCH-TODO.md`.

### Umgebungs-Realität (wichtig, ehrlich dokumentiert — ADR-0001)
- **Godot ist in dieser Cloud-Umgebung nicht installierbar** (github.com-Release-Download per Egress-Policy geblockt, HTTP 403). Ich kann Godot hier **nicht ausführen**.
- **Lokal verifizierbar:** GDScript-Lint (`gdlint` via gdtoolkit 4.5.0 — läuft), Content-JSON-Validierung (Python).
- **Nur in CI / auf Menschen-Maschine verifizierbar:** echter Godot-Lauf, Unit-Tests, Determinismus-Doppellauf.
- **Konsequenz:** GitHub-Actions-CI ist die maßgebliche Verifikationsschleife. Ein Commit gilt erst als verifiziert, wenn die CI grün ist.

- **AP 0.3 (Content-Schema v1)** ✅ — `docs/content-schema.md`, `content/schema/*`, 13 Beispiel-Objekte, `tools/validate_content.py` (grün + Negativtest bestätigt Greifen).
- **CI-Grundgerüst** ✅ — `.github/workflows/ci.yml`: Job `lint-content` (gdlint/gdformat/Content-Validierung, lokal verifiziert) + Job `godot` (Godot 4.5 headless, Projekt-Import; Test-Runner-Aufruf ab Phase 1 aktiv).

### CI-Status: BEIDE JOBS GRÜN ✅ (Run #1, Commit fcb5d29)
- `lint-content` grün (gdlint, gdformat, Content-Validierung).
- `godot` grün: **Godot 4.5-stable ließ sich laden** (bestätigt die Versionsannahme aus ADR-0001, war zuvor nur „Glaube ich") und das Projekt importierte ohne Script-/Ladefehler → project.godot, Main.tscn/Main.gd sind gültiges Godot 4.5.

### Offen / als Nächstes
- Phase 1, AP 1.1 (`core/`-Kernzustand & Zug-Loop) — siehe `NEXT.md`.

### Risiken
- **Godot-Version (Glaube ich: 4.5):** aus gdtoolkit-Signal abgeleitet, nicht direkt verifiziert. Mensch pinnt final (MENSCH-TODO).
- **Keine lokale Godot-Ausführung:** erhöht die Abhängigkeit von CI-Latenz; Gegenmaßnahme: strenges lokales Linting + JSON-Validierung vor jedem Push.

### Selbstkontrolle Phase 0
- [x] AP 0.1 DoD (Notizen im Repo)
- [~] AP 0.2 DoD (Skelett steht; Handy-Export = Mensch, MENSCH-TODO)
- [x] AP 0.3 DoD (Schema + 9 Beispiele, Validator grün)
- [~] Phase-0-Abschluss: Schema steht ✅; „leeres Projekt lauffähig" wartet auf ersten grünen CI-`godot`-Job

---

## 2026-09-07 — BLOCK 2 (Phase 3: Run-Struktur) ✅ CI-verifiziert → **STOPP 1**

**Was gebaut wurde**
- **Ganzer Run spielbar:** seeded **Pfadkarte** (`run_map.gd`, Knoten Begegnung/Ereignis/Imkerbesuch/Boss), 3 Akte, **persistenter `ColonyState`** über Begegnungen, **Einwinterungs-Bewertung** (kein/Bronze/Silber/Gold aus `run.json`).
- **`RunController`** als einziger Eingabe-Trichter (Aktions-Log) → **Save = Seed + Aktionen**, **Replay bitidentisch**; atomares Save (`save_service.gd`, `schemaVersion`).
- **Imkerbesuch** (kaufen/entfernen/Relikt), **Ereignisse** (Optionen → persistente Effekte), **Belohnung** 1-aus-3 ins Deck.
- **Greybox spielt den ganzen Run** (alle Phasen, lokalisiert, DE/EN-Umschalter).
- **CI: beide Jobs grün, ALLE 83 TESTS GRUEN** (Run 1220099).

**Akzeptanzkriterien:** K1–K9 abgehakt (`docs/blocks/block-2-run-struktur.md`), 0/5 Nachbesserungsrunden.

**Abweichungen vom Blueprint:** Standortwechsel-Knoten auf später verschoben (**ADR-0005**) — hängt an den Akt-Varianten, die der Blueprint selbst als „Später" führt.

**Was ungeprüft blieb (ehrliche Grenze):** Balance ist **grob** (voller Content + Zahlen = Block 3); Optik ist **Greybox** (echte UI = Block 4); die visuelle Darstellung ist bis zu deinem Debug-Build durch nichts geprüft (CI prüft Logik + Off-tree-Full-Run-Smoke). Spaß-Gate weiter offen.

**→ STOPP 1 (LOOP §4):** Du spielst einen Debug-Build. Materialien: **`docs/stops/stopp-1.md`** (Kurzbericht, Build-Anleitung, konkrete Fragen). **Block 3 wird NICHT automatisch gezogen** — er hängt von deinem Urteil „trägt der Kern-Loop?" ab.

---

## 2026-09-07 — LOOP-Modus aktiv · BLOCK 1 (Lokalisierung) ✅ CI-verifiziert

Ab jetzt gilt `LOOP.md` (großer-Block-Modus, drei Stopps, Kriterien-zuerst).

**Was gebaut wurde**
- i18n-Service `core/loc.gd` (statisch/headless): `assets/i18n/{de,en}.json`, `t()/set_locale()/get_locale()/has_key()`, Fallback, TranslationServer-Registrierung.
- **DE + EN vollständig** (79 Keys, paritätisch): UI-Chrome, Karten-Namen/-Texte, Bedrohungs-Namen/-Texte, **Intent-Anzeigenamen** (neues optionales `name_key` im Threat-Schema), Ereignisse, Relikte.
- **Greybox komplett lokalisiert** + **Live-DE/EN-Umschalter**; kein hartkodierter Anzeigetext mehr.
- **Maschinelle Vollständigkeitsprüfung** `tools/validate_i18n.py` (Parität, Leerwerte, alle in Content+UI referenzierten Keys) → in CI eingehängt; Negativtest bestätigt Greifen.
- Tests: `test_loc` (6), `test_greybox_language_switch`. **ALLE 67 TESTS GRUEN.**

**Akzeptanzkriterien:** K1–K7 alle abgehakt (`docs/blocks/block-1-lokalisierung.md`), 0/5 Nachbesserungsrunden.

**Abweichungen vom Blueprint:** keine — DE/EN ist in Serien-Handbuch §1.7 und Blueprint AP 5.2 vorgesehen.

**Ungeprüft geblieben (ehrliche Grenze):** die visuelle **Darstellung** der Greybox (Godot lokal nicht ausführbar) — CI prüft Parse + Off-tree-Verhalten + Sprachwechsel-Logik, aber nicht das Aussehen; das bleibt Nicos Debug-Build (Spaß-Gate). `kompendium_key` und `core/GameLog`-Zeilen bewusst nicht lokalisiert (dokumentierte Scope-Grenze).

**Regel ab jetzt:** kein neuer Text ohne Key in beiden Sprachen (CI erzwingt es).

**Nächster Block (automatisch gezogen): Block 2 — Phase 3 Run-Struktur → danach STOPP 1.**

---

## 2026-07-21 — Phase 2 (SPASS-GATE) vorbereitet ✅

### Erledigt (was ich liefern kann — der Gate-Entscheid bleibt Mensch)
- **Greybox spielbar:** `ui/Greybox.tscn` + `Greybox.gd` (Minimal-UI, tap-to-play, Zustandsleisten, Intent, Belohnung/Neuer-Run) über den headless Kern; `main_scene` gesetzt.
- **Roher Greybox-Kartensatz:** 8 neue Sammlerin/neutral/wehrhafte-Karten mit **Siegweg** (Offense/Economy/Behandlung/Defense/Trade-off) + 1 sanfte Akt-1-Bedrohung (`wespe_einzeln`). Schema-valide. **Balancing = Phase 4.**
- **Headless UI-Smoke-Test** (`test_greybox_ui`): instanziiert die UI off-tree, spielt/beendet/neustartet — fängt Laufzeit-API-Fehler vor dem Tester-Build.
- **Gate-Materialien:** `docs/gate/kill-kriterien.md`, `testerbogen.md`, `debug-build-anleitung.md`. MENSCH-TODO-Eintrag verlinkt.

### CI: BEIDE JOBS GRÜN ✅ (Run ed02bd8) — **ALLE 61 TESTS GRUEN** (inkl. `test_greybox_ui` Off-tree-Smoke)
- Gelöst: Godot 4.5 wertet `:= aus Variant` (`max()`) auch beim **Import** als Fehler; `project.godot`-Setting greift dort nicht → explizit typisiert + **CI-Variant-Wächter** (grep im Lint-Job, lokal identisch prüfbar) ergänzt.

### ⚠️ Prüf-Grenze (CLAUDE.md-Pflichtmarker)
**Ab hier ist Investition durch kein menschliches Gate geprüft.** Das Spaß-Gate (ADR-0002) ist vorbereitet, aber noch **nicht** durchgeführt. Ich baue Phase 3 autonom weiter — der Go/Rework/Kill-Entscheid mit ≥10 Testern steht aus (`MENSCH-TODO.md`). Die **UI-Darstellung** ist bis zum ersten Debug-Build durch nichts geprüft (nur Parse + Off-tree-Smoke).

### Als Nächstes
- Phase 3 (Run-Struktur) — siehe `NEXT.md`.

---

## 2026-07-21 — Phase 1 AP 1.3 + PHASE 1 ABGESCHLOSSEN ✅ CI-verifiziert

### Erledigt (AP 1.3)
- **Varroa-Schwellen-Verschlechterung (Signature-Mechanik, ADR-0004):** Milbendruck (0–3 aus Schwellen [8,14,20]) senkt vom Volk ausgehende Wirkungen; Behandlung bleibt wirksam (kein Todesspiral).
- **Bedrohungs-KI:** Phasenprogression (`THREAT_PHASE_LENGTH`), phasengated Intents werden eligible, `escalation_bonus` (per_turn/per_phase) steigert eingehenden Schaden über die Begegnung.
- **Begegnungsabschluss:** `flee()` + Belohnungswahl 1-aus-3 (`RewardUtil`, seeded `reward`-Strom, deterministisch). Anwenden aufs Run-Deck = Phase 3.
- **Autoplayer v0** (`SimUtil.play_random_legal`, eigener Policy-RNG).

### CI: BEIDE JOBS GRÜN ✅ (Run 7223bde) — **ALLE 60 TESTS GRUEN**
(test_rng 4 · test_interpreter 18 · test_interpreter_ops 14 · test_turn_engine 11 · test_threat_ai 9 · test_autoplayer 2 · test_determinism 2). **Autoplayer übersteht 100 Begegnungen ohne Crash (DoD AP 1.3).**

### Phase-1-Abschluss (Blueprint DoD)
- [x] Karten-Engine + Effekt-Interpreter headless, alle 25 Primitive
- [x] Determinismus-Doppellauf bitidentisch · Save-Snapshot vorhanden
- [x] Bedrohungs-KI/Intent, Varroa-Eskalation, Sieg/Niederlage/Flucht + Belohnung
- [x] Autoplayer v0 crashfrei (100 Begegnungen)
- [x] CI grün als Release-Bedingung

### Als Nächstes — Phase 2 (SPASS-GATE, Mensch-Gate)
- Greybox-Minimal-UI über den Kern bauen (erste `ui/`-Schicht) + Testermaterialien (Bogen, Kill-Kriterien als Datei) vorbereiten. **Go/Rework/Kill entscheidet ein Mensch mit ≥10 Testern** (Eintrag in `MENSCH-TODO.md`). Details `NEXT.md`.

---

## 2026-07-21 — Phase 1 AP 1.2 (Effekt-Interpreter fertig) ✅ CI-verifiziert

### Erledigt
- **`retain_hand`** echt: Zug-Flag, Hand wird am Zugende nicht abgelegt (Reset zu Zugbeginn).
- **`scry`** echt: Kern enthüllt Top-N in `EncounterState.scry_reveal` (Seam; Umsortier-/Ablage-Entscheidung = UI Phase 5 / Autoplayer Phase 4).
- **Interpreter-Testabdeckung** auf alle 25 Ops + Kombinationen (`double_next`×`scale`, `benommen` reduziert Bedrohungsschaden). Suite gesplittet (`test_interpreter` + `test_interpreter_ops`) wegen gdlint-20-Methoden-Limit.
- **Upgrade-Mechanik** getestet (`sammelflug` +6→+9, `sammelmotor` Kosten 2→1).
- **`content-schema.md §6`** Entscheidungen festgezurrt (discard-Default, `double_next`×`scale`, `retain_hand`, `scry`).

### CI-Status: BEIDE JOBS GRÜN ✅ (Run 135d9a6) — **ALLE 49 TESTS GRUEN**
(test_rng 4 · test_interpreter 18 · test_interpreter_ops 14 · test_turn_engine 11 · test_determinism 2)

### Als Nächstes
- AP 1.3: Bedrohungs-KI (Intent-Phasen/Eskalation echt), **Varroa-Schwellen-Verschlechterung** (Signature-Mechanik), Sieg/Niederlage/Flucht mit Belohnungswahl, Autoplayer v0 (100 Begegnungen crashfrei).

---

## 2026-07-21 — Phase 1 AP 1.1 (Kernzustand & Zug-Loop) ✅ CI-verifiziert

### Erledigt
- **ADR-0003:** Zug-Loop-Reihenfolge, Schaden-/Varroa-Regeln, provisorische Balance fixiert (VOR dem Code).
- **`core/` Sim-Kern** (strikt headless, Integer, seeded RNG): `RngService` (Ströme deck/threat/event/map, Fisher-Yates, weighted_pick), `Balance`, `CardLib`, `GameLog`, `ContentDB`, `EncounterState`/`ThreatState`/`RunState` (mit Snapshot), `EffectInterpreter` (alle 25 Primitive + scale/condition), `TurnEngine` (Zustandsmaschine nach ADR-0003), `SimUtil`.
- **Tests (eigener Headless-Runner):** **32 Tests grün in CI** — RNG-Determinismus/Unabhängigkeit, 18 Interpreter-Primitive, Zug-Loop/Sieg/Niederlage/Relikt, **Determinismus-Doppellauf bitidentisch (DoD AP 1.1)**.
- **`tools/demo.gd`:** Konsolen-Demo (gescripteter Zug mit Textausgabe).

### CI-Status: BEIDE JOBS GRÜN ✅ (Run 87cd5a8)
- `godot`-Job führt `run_tests.gd` real aus: „ALLE 32 TESTS GRUEN". Godot v4.5.stable bestätigt.

### Gelöste Stolpersteine (dokumentiert fürs Lernen)
- **SceneTree-Runner hing headless:** `quit()` allein beendet den MainLoop nicht zuverlässig → `_process()` gibt `true` zurück (Backstop); CI zusätzlich mit `--quit-after` + Sentinel-Prüfung + `concurrency`/Timeouts abgesichert.
- **Godot 4.5 wertet `INFERRED_DECLARATION` (`:=` aus Variant, z. B. `min()`/`max()`) als Fehler** → 5 Stellen explizit typisiert; `project.godot` senkt die Warnung defensiv auf „Warn". (Lokal via gdlint NICHT fangbar — CI ist hier der Wächter.)

### Als Nächstes
- AP 1.2 (Interpreter-Testabdeckung auf alle 25 Ops erweitern, Upgrade-Mechanik-Tests, `retain_hand`/`scry` echt implementieren) → siehe `NEXT.md`.

---

## Phasen-Checkliste (Blueprint Abschnitt 9)

- [x] **Phase 0** — Setup, Marktcheck, Schema ✅ (CI grün)
- [x] **Phase 1** — Karten-Engine + Effekt-Interpreter (headless) ✅ (60 Tests, CI grün)
- [~] **Phase 2** — Greybox (SPASS-GATE): vorbereitet ✅, Gate-Durchführung = Mensch (ADR-0002 offen)
- [ ] **Phase 3** — Run-Struktur  ← *als Nächstes (autonom)*
- [ ] Phase 3 — Run-Struktur
- [ ] Phase 4 — Content & Balancing (137 Objekte)
- [ ] Phase 5 — UI/UX
- [ ] Phase 6 — Art & Audio
- [ ] Phase 7 — Monetarisierung (Demo-Gate + IAP)
- [ ] Phase 8 — QA & Balancing-Beta
- [ ] Phase 9 — Store-Vorbereitung & Submission
- [ ] Phase 10 — Launch & Iteration
