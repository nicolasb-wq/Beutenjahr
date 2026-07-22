# Spaß-Gate — Kill-Kriterien (VORAB fixiert)

- **Phase:** 2 (Blueprint AP 2.2) · **Status:** fixiert vor dem Test, nicht nachträglich aufweichen
- **Zweck:** ehrlich entscheiden, ob der Kernloop trägt — **bevor** 70–95 h Content produziert werden.

## Kriterien (mindestens 10 Tester, Mischung Rafael-Typ + Nadine-Typ)

| # | Kriterium | Schwelle |
|---|---|---|
| K1 | **Wiederspiel-Reflex:** Tester startet **unaufgefordert** einen zweiten Run | **≥ 6 / 10** |
| K2 | **Lesbarkeit der Signature-Mechanik:** Tester erklärt den Varroa-Mechanismus in **einem Satz** | **≥ 7 / 10** |

## Entscheidungslogik → ADR-0002 (Go / Rework / Kill)

- **Beide Schwellen erreicht → GO.** Weiter mit Phase 3.
- **Eine/beide knapp verfehlt → REWORK:** genau **eine** Iteration (max. 15 h) + Mini-Gate mit denselben Kriterien.
- **Mini-Gate scheitert erneut → KILL.** Projekt stoppen. Das ist ein **Erfolg des Systems** (80–95 h verloren statt 350+), kein Scheitern der Person.

## Wichtig
- Greybox **nicht** vor dem Test „hübsch machen" — Schönheit verfälscht das Urteil über den Kern (Blueprint-Stolperfalle AP 2.2).
- Ergebnis (Zahlen + Zitate + Entscheid) in `docs/decisions/ADR-0002-spass-gate.md` festhalten.
