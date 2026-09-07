# ADR-0005 — Knotentyp „Standortwechsel" auf später verschoben

- **Status:** Akzeptiert · **Datum:** 2026-09-07 · **Kontext:** Block 2 (LOOP §6-Abweichung)

## Was
Der Blueprint (AP 3.1) nennt für die Pfadkarte u. a. den Knotentyp **„Standortwechsel"**.
In Block 2 (v1 der Run-Struktur) werden nur `encounter`, `event`, `shop` (Imkerbesuch)
und `boss` umgesetzt. Standortwechsel entfällt vorerst.

## Warum
„Standortwechsel" hängt inhaltlich an den **Akt-Varianten Stadt/Land/Berg**, die der
Blueprint (Feature-Scope, Abschnitt 4) ausdrücklich als **„Später/Kann"** einstuft. Ohne
diese Varianten wäre ein Standortwechsel-Knoten ein leerer Platzhalter. Der Kern-Loop
(Trägt der Run?) lässt sich mit den vier v1-Typen vollständig prüfen.

## Alternative
Standortwechsel als reiner Buff-/Rast-Knoten umsetzen — verworfen, weil das den späteren,
inhaltlich anderen Standort-Mechanismus vorwegnähme und Wegwerf-Arbeit wäre.

## Konsequenz
Kein Datenmodell verbaut Standortwechsel: Der Generator kennt Knotentypen als Daten und
kann `standortwechsel` später ergänzen, ohne den Graphen umzubauen. Wird mit den
Akt-Varianten nachgezogen.
