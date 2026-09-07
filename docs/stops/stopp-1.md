# STOPP 1 — Debug-Build spielen (nach Block 2)

**Prüffrage (LOOP §4):** *Trägt der Kern-Loop über einen ganzen Run?*

Du spielst jetzt selbst einen Debug-Build auf dem Mac. Der Loop hat währenddessen an **feedback-unabhängigen** Teilen weitergearbeitet (Tests/Doku/Tooling) und **nicht** an Block 3 begonnen — das hängt von deinem Urteil hier ab.

## Kurzbericht (was seit Block 1 dazugekommen ist)
- Ein **ganzer Run** ist spielbar: 3 Akte über eine seeded **Pfadkarte** (Knoten: Begegnung / Ereignis / Imkerbesuch / Boss), persistenter **Volkszustand** (Volksstärke/Vorräte/Varroa/Deck/Relikte) über Begegnungen hinweg, **Einwinterungs-Bewertung** am Ende (kein/Bronze/Silber/Gold).
- **Imkerbesuch** (Shop): Karte kaufen, Karte **entfernen** (Deck-Hygiene), Relikt nehmen. **Ereignisse** mit Optionen. **Belohnung** (1 aus 3) nach gewonnener Begegnung wandert ins Deck.
- **Speichern** ist atomar mit `schemaVersion`; **Replay** (Seed + Aktionsliste) reproduziert einen Run bitidentisch.
- Alles **zweisprachig** (DE/EN, Umschalter in der Greybox).
- **CI:** beide Jobs grün, **83 Tests** (inkl. voller-Run-Smoke durch die UI).

## So baust du den Build
Siehe `docs/gate/debug-build-anleitung.md` (Desktop **F5** genügt). `main_scene` ist die Greybox; sie startet direkt in einen Run. Godot **4.5-stable**.

## Bedienung
Oben: Titel, **Akt + Jahreszeit**, **Volk**-Zeile, Buttons **Sprache wechseln** / **Neuer Run**. Darunter die aktuelle Phase:
- **Nächster Schritt:** Knoten-Buttons (Begegnung/Ereignis/Imkerbesuch/Boss) — einen wählen.
- **Begegnung:** Karten-Buttons spielen, „Zug beenden".
- **Ereignis/Imkerbesuch/Belohnung:** Options-Buttons.
- **Ende:** Einwinterungs-Stufe oder „Volk zusammengebrochen".

## Konkrete Fragen, auf die du beim Spielen achten sollst
1. **Trägt der Loop über einen ganzen Run?** Bleibt es über 3 Akte interessant, oder zieht es sich / wird beliebig?
2. **Entscheidungen:** Fühlen sich Pfadwahl (Fight vs. Shop vs. Event) und Kartenwahl wie **echte Abwägungen** an — oder klickst du nur durch?
3. **Varroa als tickende Uhr:** Spürst du den Milbendruck über den Run? Ist „behandeln vs. sammeln" eine echte Spannung? (Balance ist noch grob — Block 3.)
4. **Imkerbesuch:** Ist **Karten-Entfernen** verständlich und sinnvoll nutzbar?
5. **Einwinterung:** Ist das Rundenende (Bronze/Silber/Gold bzw. Kollaps) ein befriedigender/lesbarer Abschluss?
6. **Lesbarkeit/Sprache:** Sind die Texte klar? Wechselt DE/EN sauber? Irgendwo noch Roh-IDs statt Namen?
7. **Stabilität:** Irgendein Absturz, Hänger oder „stuck" (kein Button führt weiter)?
8. **Neustart-Reflex:** Willst du nach Ende sofort „Neuer Run" drücken?

## Bewusste Grenzen (ehrlich)
- **Optik = Greybox** (hässlich mit Absicht; echte UI/Art = Block 4).
- **Balance ist grob** (voller Kartensatz + Zahlenbalance = Block 3). Es geht hier **nur** um „trägt der Loop?".
- Die Pfadkarte ist eine **Liste** (kein Graph-Bild); Kanten sind v1 voll-verbunden. Standortwechsel-Knoten kommt später (ADR-0005).
- Das **Spaß-Gate** (≥10 Tester, ADR-0002) ist davon unberührt und weiter offen (`MENSCH-TODO.md`).

## Dein Feedback
Kann jederzeit kommen (auch mitten im nächsten Block) und wird als eigener Fix-Task eingeplant. Ein **Kill/Rework** überschreibt den Loop.
