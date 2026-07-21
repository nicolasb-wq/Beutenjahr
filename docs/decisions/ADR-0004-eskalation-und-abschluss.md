# ADR-0004 — Varroa-Eskalation, Bedrohungs-Phasen & Begegnungsabschluss

- **Status:** Akzeptiert (v1, Balancing in Phase 4/8)
- **Datum:** 2026-07-21
- **Bezug:** Blueprint AP 1.3 (Bedrohungs-KI, Varroa-Eskalation, Abschluss + Belohnung), USP 1 (Varroa als Signature-Mechanik)

## 1. Varroa-Schwellen-Verschlechterung (die Signature-Mechanik)

Varroa ist die tickende Uhr: je höher die Last, desto schwächer wirken die Karten des Volks — bis man behandelt. Modell:

- `Balance.VARROA_THRESHOLDS = [8, 14, 20]` (provisorisch, **Unsicher**). Der **Milbendruck** ist die Zahl erreichter/überschrittener Schwellen (0–3): `varroa_pressure(varroa)`.
- Bei **vom Volk ausgehenden Wirkungen** (`source_side == colony`) wird der Wert um den Milbendruck **gesenkt** (Floor 0), und zwar für: `gain_stores` (nach `sammeltrieb`-Bonus), `gain_guards`, `heal`→colony, `deal_damage`→threat.
- **Nicht** gesenkt: `reduce_varroa`/`dampen_varroa` (Behandlung bleibt wirksam — kein Todesspiral-Lock), `draw`/`gain_energy` (strukturell), sowie alle Bedrohungswirkungen.

**Begründung:** Der Druck belohnt rechtzeitiges Behandeln (thematisch korrekt) statt das Volk hart zu lähmen. Schwellen ≥ 8 lassen den ruhigen Frühphasen-Start (Start-Varroa 3) unberührt.

## 2. Bedrohungs-Phasen

- `ThreatState.phase = 1 + (turn_number - 1) / Balance.THREAT_PHASE_LENGTH` (Integer-Division), `THREAT_PHASE_LENGTH = 3`.
- Intents mit `phase`-Feld werden erst ab dieser Phase auswählbar (z. B. Wespen/`uebermacht` ab Phase 2 = Runde 4). Kombiniert mit `min_turn`.

## 3. Eskalations-Bonus

- `threat.escalation_bonus` wächst deterministisch je Zugbeginn aus `escalation`:
  - `per_turn`: `(turn_number - 1) * value`
  - `per_phase`: `(phase - 1) * value`
  - `none`/fehlt: 0
- Der Bonus wird auf **von der Bedrohung ausgehenden** `deal_damage` (Ziel colony) addiert — der Druck steigt über die Begegnung. Turn 1 = 0 (kein Sprung im ersten Zug).

## 4. Begegnungsabschluss

- **Sieg** (`threat.hp ≤ 0`) → Belohnungswahl: `EncounterState.reward_choices` erhält bis zu 3 **verschiedene** Karten-ids (seeded, eigener RNG-Strom `reward`), gezogen aus dem Nicht-`special`-Kartenpool (Pool vor dem Mischen sortiert → maschinenunabhängig deterministisch). Das **Anwenden** aufs Run-Deck ist Phase 3 (Run-Struktur); AP 1.3 liefert nur die Auswahl.
- **Niederlage** (`strength ≤ 0`) → `result = "lost"`.
- **Flucht** (`flee()`) → `result = "fled"` (nur solange die Begegnung nicht entschieden ist).

## 5. Autoplayer v0

- `SimUtil.play_random_legal(engine, seed, max_turns)`: spielt je Zug **zufällig eine legale Karte**, bis keine mehr legal ist, dann Zugende. Eigener seeded RNG (unabhängig von den Spielströmen — die Policy ist Eingabe, nicht Spielzustand).
- Zweck: Crashfreiheit-Nachweis (DoD: 100 Begegnungen ohne Absturz). Der **greedy + 20 % Zufall**-Bot für echtes Balancing folgt in Phase 4 (AP 4.2).

## Alternativen erwogen
- **Varroa-Druck als Strafschaden/Zug** statt Wirkungs-Senkung: verworfen — „verschlechtert Kartenwirkungen" (Blueprint) trifft die Mechanik direkter und ist lesbarer.
- **Behandlung ebenfalls senken:** verworfen — erzeugt einen unentrinnbaren Todesspiral, widerspricht der Nordstern-Lesbarkeit.
