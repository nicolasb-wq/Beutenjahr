# Content-Schema v1 (AP 0.3)

- **Datum:** 2026-07-21 · **Status:** v1 (wird in Phase 1 gegen den echten Interpreter geschärft)
- **Zweck:** Das datengetriebene JSON-Fundament, auf dem alle 137 Content-Objekte (75 Karten, 24 Bedrohungen, 18 Ereignisse, 20 Relikte) aufbauen. Neue Karte = neue JSON-Datei, kein Code (Blueprint 7.2).
- **Grenze (ehrlich):** ~10 % der Karten brauchen erfahrungsgemäß Spezialcode → dafür der `custom_effect`-Hook statt Vokabular-Aufblähung (Blueprint-Stolperfalle AP 0.3).

Alle Objekte liegen als **eine Datei pro Objekt** unter `content/<typ>/<id>.json`. Der Loader (Phase 1) glob't das Verzeichnis. Maschinelle Prüfung: `content/schema/*.schema.json` (+ `tools/validate_content.py`), läuft lokal und in CI.

---

## 1. Ressourcenmodell (Kontext für alle Effekte)

Der Begegnungszustand kennt beim **Volk (colony)**:

| Ressource | Rolle | Persistenz |
|---|---|---|
| **Volksstärke** (`strength`) | ≈ HP; sinkt durch Bedrohungsaktionen; 0 = Run verloren | persistent über den Run |
| **Vorräte** (`stores`) | Honig/Pollen; Energie-Nachschub, Einwinterungs-Wert | persistent über den Run |
| **Varroalast** (`varroa`) | tickende Uhr; wächst pro Runde; Schwellen verschlechtern Effekte | persistent über den Run |
| **Arbeiterinnen** (`energy`) | Spielkosten pro Zug; füllt sich zu Zugbeginn auf | pro Zug |
| **Wächterinnen** (`guards`) | Schadensschild; fängt `deal_damage` ab; verfällt zu Zugbeginn (außer `propolis`) | pro Zug |
| Hand / Ziehstapel / Ablagestapel | Kartenfluss | pro Begegnung |

Die **Bedrohung (threat)** kennt `hp` und ein Intent (angekündigte nächste Aktion).

---

## 2. Effekt-Vokabular v1 (25 Primitive)

Ein Effekt ist ein Objekt:

```json
{ "op": "gain_guards", "value": 5, "target": "colony",
  "scale": { "per": "stores", "factor": 1 },
  "condition": { "if": "varroa_over", "value": 3 } }
```

- `op` (Pflicht): eines der 25 Primitive unten.
- `value` (meist Pflicht): ganzzahlig (**nur Integer** im Kern — ADR-0001).
- `target` (optional): `colony` (Standard) oder `threat`.
- `scale` (optional): `value += floor(metric * factor)`; Modifikator, kein Primitiv.
- `condition` (optional): Effekt wirkt nur, wenn wahr; Modifikator, kein Primitiv.

**Scope** steuert, wo ein Op erlaubt ist: `enc` = nur in Begegnungen (Karten/Intents/Kampf-Relikttrigger); `pers` = auch außerhalb (Ereignisse, Run-Trigger), weil es dauerhaften Volkszustand ändert. Der Validator erzwingt: **Ereignis-Effekte dürfen nur `pers`-Ops (oder `custom_effect`) nutzen.**

### Volk-Ressourcen (6)
| Op | Wirkung | Scope |
|---|---|---|
| `heal` | Volksstärke (bzw. `threat`-HP) + `value` | pers |
| `gain_stores` | Vorräte + `value` | pers |
| `spend_stores` | Vorräte − `value` (Kosten/Räuberei; nie unter 0) | pers |
| `gain_energy` | Arbeiterinnen diese Runde + `value` | enc |
| `gain_max_energy` | Arbeiterinnen-Maximum diese Begegnung + `value` | enc |
| `gain_guards` | Wächterinnen + `value` (Ziel: colony) | enc |

### Varroa (3)
| Op | Wirkung | Scope |
|---|---|---|
| `add_varroa` | Varroalast + `value` (Kosten starker Karten; Bedrohungsaktion) | pers |
| `reduce_varroa` | Varroalast − `value` (Behandlungen; nie unter 0) | pers |
| `dampen_varroa` | Varroa-**Wachstum** die nächsten `value` Runden aussetzen/halbieren | enc |

### Bedrohung (3)
| Op | Wirkung | Scope |
|---|---|---|
| `deal_damage` | Schaden an `target` (colony: erst Wächterinnen abziehen; threat: HP −) | enc |
| `weaken_threat` | nächste Bedrohungsaktion − `value` | enc |
| `delay_intent` | Bedrohungsaktion um `value` Runden verschieben | enc |

### Karten / Deck (6)
| Op | Wirkung | Scope |
|---|---|---|
| `draw` | `value` Karten ziehen | enc |
| `discard` | `value` Karten ablegen (Ziel-Regel via `target`/`select`) | enc |
| `generate_card` | Karte `card_id` erzeugen (in Hand/Ziehstapel; Ereignis: in Deck) | pers* |
| `exhaust_self` | diese Karte nach dem Spielen aus dem Run entfernen (einmalig stark) | enc |
| `retain_hand` | diese Karte bleibt bei Zugende auf der Hand | enc |
| `scry` | oberste `value` Ziehkarten ansehen/umsortieren/ablegen | enc |

\* `generate_card` ist `pers`, wenn es dem Deck eine Karte hinzufügt (Ereignis), sonst `enc`.

### Status & Skalierung (3)
| Op | Wirkung | Scope |
|---|---|---|
| `apply_status` | `status` mit `value` Stapeln auf `target` legen | enc |
| `remove_status` | `status` von `target` entfernen | enc |
| `scale_per_turn` | benannten Status legen, der pro Runde um `value` wächst (Motor-Karten) | enc |

### Fluss (3)
| Op | Wirkung | Scope |
|---|---|---|
| `heal_start_of_turn` | Regeneration: `value` Volksstärke je Zugbeginn (Rest der Begegnung) | enc |
| `double_next` | die nächste gespielte Karte verdoppelt ihre `value`-Felder | enc |
| `convert` | `from` → `to` im Verhältnis `ratio` (z. B. Vorräte → Volksstärke: Auffütterung) | pers |

### Hook (1)
| Op | Wirkung | Scope |
|---|---|---|
| `custom_effect` | benannter GDScript-Callable (`hook`), für die ~10 % Sonderfälle | beides |

---

## 3. Modifikatoren

### `scale` — Wert an Zustand koppeln
`per` ∈ { `stores`, `strength`, `varroa`, `guards`, `hand_size`, `cards_played` } · `factor` ganzzahlig.
Berechnung: `effektiver_value = value + floor(metric * factor)`.

### `condition` — Bedingter Effekt
`if` ∈ { `varroa_over`, `varroa_under`, `stores_over`, `stores_under`, `strength_under`, `brood_free`, `has_status` }.
`value` (bei Schwellen) bzw. `status` (bei `has_status`). `brood_free` bildet die reale „nur brutfrei stark"-Timing-Mechanik ab (z. B. Oxalsäure) — Blueprint 3.2.

### Status-Vokabular v1 (datengetrieben erweiterbar)
- **colony:** `propolis` (Wächterinnen bleiben liegen), `sammeltrieb` (`gain_stores`-Effekte +Stapel), `kraft` (`deal_damage` +Stapel), `regeneration` (Volksstärke je Zug +Stapel), `zaehigkeit` (erste Stapel Schaden/Runde ignoriert).
- **threat:** `benommen` (nächste Aktion −Stapel), `markiert` (erleidet +Stapel Schaden), `verlangsamt` (Intent +1 Runde/Stapel).

---

## 4. Objekt-Schemata

### 4.1 Karte (`content/cards/<id>.json`)
```json
{
  "id": "sammelflug",
  "name_key": "card.sammelflug.name",
  "text_key": "card.sammelflug.text",
  "type": "aktion",                 // aktion | faehigkeit | ereigniskarte
  "cost": 1,                        // Arbeiterinnen-Einsatz (Integer ≥ 0)
  "rarity": "common",              // common | uncommon | rare | special
  "archetype": "sammlerin",        // sammlerin | wehrhafte | zuechterin | neutral
  "act": 1,                         // frühester Akt, in dem die Karte auftauchen darf
  "effects": [ ... ],               // Liste von Effekt-Objekten
  "upgrade": { "cost": 0 },        // partielle Überschreibung ("geimkert"-Variante)
  "kompendium_key": "card.sammelflug.fact"  // optional: Fach-Notiz-Key
}
```
- `type`: `aktion` (einmalig), `faehigkeit` (bleibende Wirkung, meist via `apply_status`/`scale_per_turn`), `ereigniskarte` (durch Effekte erzeugte Wegwerfkarte).
- `upgrade`: jedes gesetzte Feld ersetzt das Basisfeld; ist `effects` gesetzt, **ersetzt** es die Basis-Effekte komplett (kein Delta-Merge — bewusst simpel).

### 4.2 Bedrohung (`content/threats/<id>.json`)
```json
{
  "id": "raeuberei_welle",
  "name_key": "threat.raeuberei_welle.name",
  "hp": 40,
  "act": 3,
  "is_boss": true,
  "escalation": { "type": "per_turn", "value": 2 },   // optional: eigener Druckaufbau
  "intents": [
    { "id": "pluendern", "weight": 3, "min_turn": 1,
      "effects": [ { "op": "spend_stores", "value": 4, "target": "colony" } ] },
    { "id": "uebermacht", "weight": 2, "min_turn": 4, "phase": 2,
      "effects": [ { "op": "deal_damage", "value": 10, "target": "colony" } ] }
  ]
}
```
- `intents`: gewichtete Tabelle (seeded gewählt). `min_turn`/`phase` steuern Eskalation (z. B. Wespen ab Runde 4 aggressiver). Intent-Effekte zielen i. d. R. auf `colony`.

### 4.3 Ereignis (`content/events/<id>.json`)
```json
{
  "id": "wildblumenwiese",
  "name_key": "event.wildblumenwiese.name",
  "text_key": "event.wildblumenwiese.text",
  "act": 1,
  "options": [
    { "label_key": "event.wildblumenwiese.opt_sammeln",
      "effects": [ { "op": "gain_stores", "value": 8 } ] },
    { "label_key": "event.wildblumenwiese.opt_ruhe",
      "effects": [ { "op": "heal", "value": 5 }, { "op": "add_varroa", "value": 1 } ] }
  ]
}
```
- **Nur `pers`-Ops** in Ereignis-Effekten (Validator erzwingt das) — Ereignisse laufen außerhalb der Begegnung.

### 4.4 Relikt (`content/relics/<id>.json`)
```json
{
  "id": "beutenbock",
  "name_key": "relic.beutenbock.name",
  "text_key": "relic.beutenbock.text",
  "rarity": "common",
  "trigger": "turn_start",          // run_start | encounter_start | turn_start | turn_end | on_play_card | on_varroa_threshold | on_stores_spent
  "trigger_value": 0,                // optional (z. B. Schwelle bei on_varroa_threshold)
  "effects": [ { "op": "gain_guards", "value": 2, "target": "colony" } ]
}
```

---

## 5. Verifikation

- **Struktur:** JSON-Schema (Draft 2020-12) je Typ unter `content/schema/`.
- **Referenzintegrität:** `validate_content.py` prüft zusätzlich: eindeutige IDs, `generate_card.card_id` verweist auf existierende Karte, Ereignis-Effekte nur `pers`-Ops, `custom_effect` hat `hook`, `act` ∈ {1,2,3}.
- **Kein Content-Objekt wird committet, das nicht maschinell validiert ist** (CLAUDE.md, Technische Leitplanken).

## 6. Geklärte Entscheidungen (AP 1.1/1.2)
- **`dampen_varroa` vs. Varroa-Tick:** `dampen_varroa` setzt `dampen_turns`; der Tick zu Zugbeginn halbiert das Wachstum, solange `dampen_turns > 0`, und dekrementiert dann (ADR-0003).
- **`double_next` × `scale`:** Reihenfolge im Interpreter ist `wert = value + floor(metrik * factor)`, **danach** ×2 bei aktivem `double_next`. `double_next` gilt für die **nächste** gespielte Karte und wird vor deren Interpretation konsumiert (setzt sie sich selbst, verdoppelt sie sich nicht).
- **`discard`-Auswahl:** `select` ∈ {`random` (Default), `all`}. `choose` (Spielerwahl) ist ein UI-Konzept und wird im Kern wie `random` behandelt, bis die UI (Phase 5) die Auswahl liefert.
- **`retain_hand`:** setzt ein Zug-Flag; am Zugende wird die Hand **nicht** abgelegt. Gilt nur für den laufenden Zug (Reset zu Zugbeginn).
- **`scry`:** der Kern enthüllt die obersten `value` Ziehkarten in `EncounterState.scry_reveal` (Seam); die Umsortier-/Ablage-Entscheidung trifft UI (Phase 5) bzw. Autoplayer (Phase 4). Die Stapelreihenfolge bleibt unverändert.
