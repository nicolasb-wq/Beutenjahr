# NEXT — der eine nächste Schritt

## Jetzt

**Phase 1, AP 1.1 — Kernzustand & Zug-Loop (`core/`, headless).**

Konkret:
1. `core/`-Klassen: `RunState`, `EncounterState` (Volksstärke, Vorräte, Varroalast, Energie, Wächterinnen, Hand/Zieh-/Ablagestapel), `ThreatState`, `RngService` (getrennte, seeded Ströme: `deck`, `threat`, `event`, `map`).
2. Zug-Loop als reine Zustandsmaschine: Zugbeginn (Energie auffrischen, ziehen, Varroa-Tick, Intent würfeln) → Spieleraktionen → Zugende → Bedrohungsaktion.
3. **Alle Regeln als Doku-Kommentar VOR dem Code** — Reihenfolge-Fragen (z. B. „wirkt Relikt vor oder nach Varroa-Tick?") jetzt festlegen, nicht im Bugfix. Auch offene Punkte aus `docs/content-schema.md §6`.
4. Minimaler Headless-Test-Runner (`tests/run_tests.gd` + `tests/test_case.gd`) — dann greift der zweite CI-Job.

**DoD:** Konsolen-Skript spielt einen gescripteten Zug mit Textausgabe; Doppellauf mit gleichem Seed = bitidentisch (Determinismus). Erste Unit-Tests grün in CI.

**Stolperfalle (Blueprint):** RNG-Ströme mischen — dann verschiebt jede neue Karte im Pool sämtliche Replays. Strikt getrennte Ströme.

## Danach

- AP 1.2 Effekt-Interpreter (die 25 Primitive aus dem Schema) + ≥25 Unit-Tests.
- AP 1.3 Bedrohungs-KI, Varroa-Eskalation, Autoplayer v0.

> Voraussetzung: erst prüfen, dass die Phase-0-CI grün ist (beide Jobs).
