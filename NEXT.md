# NEXT — der eine nächste Schritt

## Jetzt

**Phase 2 — SPASS-GATE vorbereiten (AP 2.1/2.2).** Das ist ein **Mensch-Gate**: den Go/Rework/Kill-Entscheid mit ≥10 Testern kann nur der Mensch fällen (ADR-0002 folgt daraus). Meine Aufgabe: alles so vorbereiten, dass der Test sofort durchführbar ist.

Konkrete nächste Schritte (klein schneiden):
1. **Greybox-Minimal-UI** über den Kern (erste `ui/`-Node-Schicht, „null Schönheit, volle Funktion"): Kartenhand als Rechtecke+Text, Tap zum Spielen, Zustandsanzeigen (Volksstärke/Vorräte/Varroa/Energie/Wächterinnen), Intent-Icon, Zug-Ende-Button. UI ruft nur den Kern auf (kein Regelcode in der UI).
2. **Akt-1-Greybox spielbar** machen (Sammlerin-Startdeck + 1–2 Begegnungen aus vorhandenem Content).
3. **Testermaterialien** als Dateien: `docs/gate/testerbogen.md` (Fragen: „Noch einen Run gestartet? Spannendste Entscheidung? Was verwirrend?") und `docs/gate/kill-kriterien.md` (VORAB fix: ≥6/10 starten unaufgefordert 2. Run; ≥7/10 erklären Varroa in einem Satz).
4. **Eintrag in `MENSCH-TODO.md`** samt Debug-Build-Anleitung.

**DoD (was ich liefern kann):** Greybox startet, ein Akt ist tap-spielbar; Testerbogen + Kill-Kriterien liegen als Dateien; Gate in MENSCH-TODO verankert.

**Wichtig (CLAUDE.md):** Nach diesem Gate in `FORTSCHRITT.md` markieren: „Ab hier ist Investition durch kein menschliches Gate geprüft." Ich darf danach autonom weiterbauen (Phase 3), aber ehrlich gekennzeichnet.

## Danach

- Phase 3 (Run-Struktur): Pfadkarte/Knoten-Graph, Akt-Übergänge, Ereignisse/Tausch/Relikte im Run, Meta-Save + Freischaltbaum, Replay-Export — und das **Anwenden** der Belohnungswahl aufs Run-Deck.

> Godot lokal nicht ausführbar → CI ist die Verifikation. Vor jedem Push: `gdlint`/`gdformat`/`validate_content.py` grün. UI-Verhalten ist headless schwerer testbar — Kernlogik bleibt in `core/` (getestet), die UI dünn halten.
