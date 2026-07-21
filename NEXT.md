# NEXT — der eine nächste Schritt

## Jetzt

**Phase 1, AP 1.3 — Bedrohungs-KI, Varroa-Eskalation & Autoplayer v0.**

Konkret (Blueprint AP 1.3):
1. **Intent-System vervollständigen:** echte Phasenwechsel (z. B. Wespen ab Runde 4 aggressiver) — `ThreatState.phase` steuern über `escalation` (`per_turn`/`per_phase`); phasengated Intents (`phase`-Feld) werden dann eligible.
2. **Varroa-Eskalationsmodell — die Signature-Mechanik (hier Zeit investieren):** Schwellen verschlechtern Kartenwirkungen. Modell definieren (z. B. ab Schwelle X: −1 auf ausgehende Werte oder Strafschaden je Zug), in ADR festhalten, testen.
3. **Begegnungsabschluss:** Sieg/Niederlage/**Flucht** inkl. Belohnungswahl (1 aus 3 Karten, seeded — Genre-Standard).
4. **Autoplayer v0:** spielt zufällig legal; übersteht **100 Begegnungen ohne Crash** (Grundlage für den Balancing-Bot in Phase 4).

**DoD (Blueprint):** Komplette Begegnung headless durchspielbar; Autoplayer übersteht 100 Begegnungen ohne Crash. Tests grün in CI.

**Stolperfalle (Blueprint):** Eskalation linear statt spürbar — Varroa muss sich wie eine tickende Uhr anfühlen; lieber zu böse starten und runterdrehen.

## Danach

- Phase 1 abgeschlossen → **Phase 2 (SPASS-GATE)**: Papier-Prototyp + Greybox. Achtung: Greybox braucht eine Minimal-UI (erste Node-Schicht über dem Kern) und ist ein **Mensch-Gate** (≥10 Tester) — vorbereiten, nicht selbst durchführen.

> CI ist die maßgebliche Verifikation. Vor jedem Push: `gdlint`/`gdformat`/`validate_content.py` lokal grün.
