# ADR-0000 — Projektwahl: „Beutenjahr"

- **Status:** Akzeptiert
- **Datum:** 2026-07-21
- **Kontext-Quellen:** `CLAUDE.md`, `Game-Blueprint_Beutenjahr_v1.md`, `Serien-Handbuch.md`

## Kontext

Aus der Zehn-Spiele-Serie wird genau **ein** Projekt gebaut (Serien-Prinzip: „ein Projekt zur Zeit"). Die Wahl ist getroffen und laut Auftrag (`CLAUDE.md`, Startbefehl) nicht neu zu diskutieren: **Beutenjahr**, ein Imkerei-Deckbuilder-Roguelite.

## Entscheidung

Wir bauen Beutenjahr nach `Game-Blueprint_Beutenjahr_v1.md` (das Gesetz für alles Spielspezifische) und `Serien-Handbuch.md` (führend für serienweite Bausteine). Bei Widerspruch gewinnt das Handbuch.

## Begründung (aus dem Blueprint übernommen, nicht neu erfunden)

- Deckbuilder-Roguelite ist ein erprobtes, hoch wiederspielbares Premium-Genre auf Mobile.
- Marktlücke: authentisches Naturthema mit echter Fachtiefe (reale Bienenbiologie als Mechanik) ist selten besetzt — vorläufig bestätigt durch den Marktcheck (`docs/marktcheck.md`, R3).
- Founder-Market-Fit: reale Imkerei-Erfahrung des Auftraggebers als Design- und Marketing-Vorteil.

## Konsequenzen

- Nordstern-Metrik (Blueprint): ein Run dauert 30–45 Min, ist in 10-Min-Häppchen unterbrechbar, Niederlagen sind lesbar. Features, die das verletzen, fliegen.
- Umsatz-Planungsfall bleibt das konservative Szenario.
- Alle konkreten Zahlen (Content-Mengen, Schwellen, Metriken) stammen ausschließlich aus dem Blueprint.

## Alternativen

Keine — die Projektwahl ist per Auftrag fixiert. Die neun anderen Serien-Blueprints sind „Regal, nicht Baustelle".
