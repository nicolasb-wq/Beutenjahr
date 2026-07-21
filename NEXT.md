# NEXT — der eine nächste Schritt

## Jetzt

**AP 0.3 — Content-Schema v1 + Effekt-Vokabular (~25 Primitive) + 9 Beispiel-JSONs.**

Konkret:
1. `docs/content-schema.md`: Felder für Karte / Bedrohung / Ereignis / Relikt festlegen.
2. Effekt-Vokabular v1 definieren (~25 Primitive) + `custom_effect`-Hook. Gegenprobe: lassen sich 10 Beispielkarten damit ausdrücken?
3. Je 3 valide Beispiel-JSONs (Karte / Bedrohung / Ereignis) von Hand.
4. JSON-Schemas + `tools/validate_content.py` für maschinelle Validierung (lokal + CI).

**DoD:** Schema-Doku + 9 valide Beispiele; `validate_content.py` grün.

## Danach

- CI-Grundgerüst (GitHub Actions): Godot-4.5-headless-Lauf, gdlint, Content-Validierung.
- Dann Phase 1, AP 1.1: `core/`-Kernzustand & Zug-Loop mit getrennten seeded RNG-Strömen.

> Regel: immer nur EIN nächster Schritt hier. Nach Erledigung fortschreiben.
