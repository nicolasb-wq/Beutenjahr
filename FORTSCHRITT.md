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

### Offen / als Nächstes
- AP 0.3 (Content-Schema + Effekt-Vokabular + 9 Beispiele) — siehe `NEXT.md`.
- CI-Grundgerüst aufsetzen.

### Risiken
- **Godot-Version (Glaube ich: 4.5):** aus gdtoolkit-Signal abgeleitet, nicht direkt verifiziert. Mensch pinnt final (MENSCH-TODO).
- **Keine lokale Godot-Ausführung:** erhöht die Abhängigkeit von CI-Latenz; Gegenmaßnahme: strenges lokales Linting + JSON-Validierung vor jedem Push.

### Selbstkontrolle Phase 0 (Zwischenstand)
- [x] AP 0.1 DoD (Notizen im Repo)
- [~] AP 0.2 DoD (Skelett steht; Handy-Export = Mensch)
- [ ] AP 0.3 DoD (Schema + 9 Beispiele)
- [ ] Phase-0-Abschluss: leeres Projekt lauffähig (CI-verifiziert) + Schema steht

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
