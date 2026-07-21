# FORTSCHRITT

Chronologisches Log. Neueste Einträge oben. Nach jeder Phase Checkliste abhaken.

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
- [ ] **Phase 1** — Karten-Engine + Effekt-Interpreter (headless)  ← *AP 1.1 fertig, AP 1.2/1.3 offen*
- [ ] Phase 2 — Papier-Prototyp + Greybox (SPASS-GATE)
- [ ] Phase 3 — Run-Struktur
- [ ] Phase 4 — Content & Balancing (137 Objekte)
- [ ] Phase 5 — UI/UX
- [ ] Phase 6 — Art & Audio
- [ ] Phase 7 — Monetarisierung (Demo-Gate + IAP)
- [ ] Phase 8 — QA & Balancing-Beta
- [ ] Phase 9 — Store-Vorbereitung & Submission
- [ ] Phase 10 — Launch & Iteration
