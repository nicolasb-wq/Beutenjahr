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

## Phasen-Checkliste (Blueprint Abschnitt 9)

- [ ] **Phase 0** — Setup, Marktcheck, Schema  ← *in Arbeit*
- [ ] Phase 1 — Karten-Engine + Effekt-Interpreter (headless)
- [ ] Phase 2 — Papier-Prototyp + Greybox (SPASS-GATE)
- [ ] Phase 3 — Run-Struktur
- [ ] Phase 4 — Content & Balancing (137 Objekte)
- [ ] Phase 5 — UI/UX
- [ ] Phase 6 — Art & Audio
- [ ] Phase 7 — Monetarisierung (Demo-Gate + IAP)
- [ ] Phase 8 — QA & Balancing-Beta
- [ ] Phase 9 — Store-Vorbereitung & Submission
- [ ] Phase 10 — Launch & Iteration
