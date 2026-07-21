# NEXT — der eine nächste Schritt

## Jetzt

**Phase 1, AP 1.2 — Effekt-Interpreter abschließen (Testabdeckung + Feinschliff).**

Der Interpreter existiert bereits (alle 25 Primitive, `core/effect_interpreter.gd`). Offen laut Blueprint AP 1.2:
1. **Testabdeckung auf alle 25 Ops** heben (aktuell 18 Interpreter-Tests) + 5 Kombinations-/Reihenfolge-Tests (z. B. `double_next` vor `scale`, `benommen` reduziert Bedrohungsschaden, `dampen_varroa` über mehrere Ticks). Ziel: ≥25 Interpreter-Tests.
2. **`retain_hand` und `scry` echt implementieren** (in AP 1.1 als v1-Platzhalter markiert) — inkl. Tests.
3. **Upgrade-Mechanik testen:** „geimkert"-Variante (`upgrade`) verändert Kosten/Effekte korrekt (z. B. `sammelflug` +6 → +9).
4. Offene Punkte aus `docs/content-schema.md §6` festzurren (discard-`select`-Regel, `double_next`×`scale`-Vertrag).

**DoD:** ≥25 Interpreter-Tests grün in CI; jedes Primitiv mindestens einmal getestet; Upgrade-Pfad getestet.

## Danach

- AP 1.3: Bedrohungs-KI (Intent-Phasen/Eskalation echt), Varroa-**Schwellen**-Verschlechterung (Signature-Mechanik!), Sieg/Niederlage/Flucht mit Belohnungswahl, Autoplayer v0 (100 Begegnungen crashfrei).

> CI ist die maßgebliche Verifikation (Godot lokal nicht ausführbar). Vor jedem Push: `gdlint`/`gdformat` + `validate_content.py` lokal grün.
