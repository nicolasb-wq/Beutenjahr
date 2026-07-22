# NEXT — der eine nächste Schritt

> ⚠️ **Prüf-Grenze (CLAUDE.md):** Das Spaß-Gate (Phase 2) ist vorbereitet, aber noch nicht von Menschen durchgeführt. Ab Phase 3 baue ich autonom weiter — Investition ab hier ist durch kein menschliches Gate geprüft (siehe `MENSCH-TODO.md`, ADR-0002 offen).

## Jetzt

**Phase 3, AP 3.1 — Pfadkarte & Akt-Fluss (headless).**

Konkret (Blueprint AP 3.1):
1. **Knoten-Graph-Generator (seeded, Strom `map`):** pro Akt ~12 Knoten in 5–6 Reihen; Typen-Mix regelgesteuert (Begegnung / Ereignis / Standortwechsel / „Imkerbesuch"=Tausch); Regeln: nie 2 Bosse hintereinander, Tausch-Knoten je Akt garantiert.
2. **Akt-Übergänge** + Akt-Bosse als besondere Begegnungen + **Einwinterungs-Bewertung** (Schwellen aus JSON → Bronze/Silber/Gold).
3. **Jahreszeiten-Färbung** als Datenfeld je Akt (billige Atmosphäre; UI erst später).

**DoD:** kompletter Run Akt 1–3 + Einwinterungs-Bewertung mit Platzhalter-Content headless durchspielbar; Tests grün in CI.

**Stolperfalle (Blueprint):** Map-Generator überkomplex — v1 simpel halten (Regeln nachschärfen geht immer).

## Danach

- AP 3.2: Ereignis-System, „Imkerbesuch"-Tausch (Karten entfernen = Deck-Hygiene!), Relikte im Run.
- AP 3.3: atomares Meta-Save (`schemaVersion`, Temp+Rename), Freischaltbaum, Replay-Export — **und** das Anwenden der Belohnungswahl (`reward_choices`) aufs Run-Deck.

> Godot lokal nicht ausführbar → CI ist die Verifikation. Vor jedem Push: `gdlint`/`gdformat`/`validate_content.py` grün. Logik in `core/` (getestet), UI dünn.
