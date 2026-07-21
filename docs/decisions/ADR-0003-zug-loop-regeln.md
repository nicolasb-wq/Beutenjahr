# ADR-0003 — Zug-Loop-Regeln, Reihenfolge & provisorische Balance

- **Status:** Akzeptiert (v1, wird in Phase 4/8 balanciert)
- **Datum:** 2026-07-21
- **Bezug:** Blueprint AP 1.1 („Alle Regeln als Doku-Kommentar VOR dem Code"), 3.2; Content-Schema §1

## Kontext

Der Blueprint verlangt, Reihenfolge-Fragen VOR dem Code zu fixieren („wirkt Relikt X vor oder nach Varroa-Tick?"), sonst werden sie zu Bugfix-Archäologie. Diese ADR legt den **verbindlichen Ablauf** einer Begegnung fest. Der `core/`-Kern implementiert genau das; Abweichungen nur per neuer ADR.

## Ressourcenmodell (Integer, ≥ 0)

| Ressource | Regel |
|---|---|
| `strength` (Volksstärke) | Volk verliert die Begegnung, wenn `strength ≤ 0` (geprüft nach Bedrohungsaktion). |
| `stores` (Vorräte) | nie unter 0; Einwinterungswert (Phase 3). |
| `varroa` (Varroalast) | wächst je Zugbeginn (Tick, s. u.); nie unter 0. |
| `energy` (Arbeiterinnen) | wird zu Zugbeginn auf `max_energy` aufgefüllt; Karten kosten Energie. |
| `guards` (Wächterinnen) | Schild; fällt zu Zugbeginn auf 0 **außer** Status `propolis`. |

## Verbindliche Zug-Reihenfolge (ein Zug = ein Spielerzug)

### A. Zugbeginn (`start_turn`), feste Unterschritte
1. `turn_number += 1`
2. `energy = max_energy`
3. `guards = has_status(propolis) ? guards : 0`
4. **Relikt-Trigger `turn_start`** (vor dem Varroa-Tick — so kann ein Relikt den Tick dämpfen)
5. **Varroa-Tick** (Wachstum, s. u.)
6. **Status-Zugbeginn:** `regeneration` heilt; `scale_per_turn`-Status wachsen um ihren Wert; Rundenzähler (`zaehigkeit`) zurücksetzen
7. **Ziehen:** bis Handlimit `HAND_SIZE` nachziehen (leerer Ziehstapel → Ablage seeded neu mischen, Strom `deck`)
8. **Intent enthüllen:** Bedrohung wählt sichtbar ihre nächste Aktion (Strom `threat`, `min_turn`/`phase`-Gating)

### B. Spieleraktionen (`play_card`, beliebig oft)
- Vorbedingung: `energy ≥ cost`. Energie zahlen, dann Effekte interpretieren (in `effects`-Reihenfolge).
- Danach Karte → Ablage; `exhaust_self` → aus dem Run entfernt; `retain_hand` markiert Verbleib.
- Relikt-Trigger `on_play_card`, `on_stores_spent`, `on_varroa_threshold` feuern an ihren Auslösern.

### C. Zugende (`end_turn`)
9. Relikt-Trigger `turn_end`
10. Hand ablegen (außer `retain_hand`-Karten)
11. **Bedrohungsaktion:** enthüllten Intent ausführen (Effekte gegen `colony`)
12. Bedrohungs-Eskalation (`escalation`, Detailmodell in AP 1.3)
13. **End-Bedingungen prüfen:** `threat.hp ≤ 0` → Begegnung gewonnen; `strength ≤ 0` → verloren

## Schaden-Regel (`deal_damage`)
- **Ziel `colony`:** erst Wächterinnen, dann Volksstärke. `absorbiert = min(guards, dmg)`; `guards -= absorbiert`; `strength -= (dmg - absorbiert)`. `strength` nie unter 0.
- **Ziel `threat`:** `hp -= dmg (+ markiert-Stapel)`. `hp` nie unter 0.
- Status `kraft` addiert seine Stapel auf ausgehenden `deal_damage`-Wert des Volks.

## Varroa-Tick (provisorisch, Detail-Eskalation in AP 1.3)
```
wachstum = VARROA_BASE_GROWTH + floor(varroa * VARROA_GROWTH_PCT / 100)
wenn dämpfung aktiv (dampen_varroa): wachstum = floor(wachstum / 2)
varroa += wachstum
```
Die **Schwellen-Verschlechterung** von Kartenwirkungen (Signature-Mechanik) wird bewusst in **AP 1.3** ausgearbeitet — hier nur das Wachstum.

## Provisorische Balance-Konstanten (`core/balance.gd`)

**Unsicher — Startwerte, keine balancierten Zahlen.** Werden in Phase 4 (Bot) und Phase 8 (Beta) empirisch gesetzt. Sie leben in `core/balance.gd`, damit sie später ohne Logikänderung wandern können.

| Konstante | Startwert | Zweck |
|---|---|---|
| `HAND_SIZE` | 5 | Handkarten je Zug |
| `START_MAX_ENERGY` | 3 | Arbeiterinnen je Zug |
| `START_STRENGTH` | 40 | Volksstärke zu Begegnungsbeginn |
| `START_STORES` | 0 | Vorräte |
| `START_VARROA` | 3 | Varroa-Startlast |
| `VARROA_BASE_GROWTH` | 1 | additiver Grundzuwachs/Zug |
| `VARROA_GROWTH_PCT` | 15 | prozentualer Zuwachs/Zug |

## Determinismus
- Getrennte, seeded RNG-Ströme `deck`/`threat`/`event`/`map` (Blueprint-Stolperfalle: Ströme mischen verschiebt alle Replays).
- Mischen via eigenem Fisher-Yates auf dem Strom `deck` — **nie** `Array.shuffle()` (nutzt globalen RNG).
- Kein `randi()`/`randf()` außerhalb der Ströme; keine Zeit-/Frame-Abhängigkeit im Kern.
- Doppellauf mit gleichem Master-Seed + gleicher Aktionsliste ⇒ bitidentischer Zustands-Snapshot (Determinismus-Test).

## Alternativen erwogen
- **Intent am Zugende statt -beginn enthüllen:** verworfen — Genre-Standard ist Vorab-Ansage (Lesbarkeit, Blueprint 3.2).
- **Guards über Zuggrenzen halten (Default):** verworfen — Block-Reset ist Genre-Standard; Halten ist der bewusste `propolis`-Effekt.
- **Float-Varroa-Wachstum:** verworfen — Integer-Only-Leitplanke (ADR-0001).
