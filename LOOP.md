# LOOP.md — Autonomer Entwicklungs-Loop für Beutenjahr

Diese Datei ist die verbindliche Arbeitsanweisung für Claude Code.
Sie wird zu Beginn **jedes** Laufs gelesen und hat Vorrang vor Gewohnheiten
aus früheren Sessions. Bei Widerspruch zu CLAUDE.md gilt: CLAUDE.md regelt
Code-Konventionen, LOOP.md regelt Ablauf, Gates und Abbruchbedingungen.

## 1. Ziel

Das Spiel so weit fertigstellen, dass am Ende **nur noch Xcode auf dem Mac**
nötig ist: Signierung, Archivierung, Upload. Alles andere ist vorher erledigt,
inklusive Store-Texte, Screenshots und Datenschutzangaben.

## 2. Grundregeln

- **Große Blöcke.** Ein Arbeitspaket ist ein ganzer Block, kein Einzeltask.
- **Selbstantrieb.** Nach Abschluss eines Blocks wird der nächste automatisch
  gezogen. Keine Freigabe pro Paket nötig, außer an den Stopps (Abschnitt 4).
- **Akzeptanzkriterien zuerst.** Vor Baubeginn eines Blocks werden dessen
  Kriterien schriftlich in `docs/blocks/<block>.md` festgelegt. Erst danach
  wird Code geschrieben. Am Ende wird jedes Kriterium einzeln abgehakt.
- **Fünf Versuche.** Scheitert ein Akzeptanzkriterium, sind maximal fünf
  eigene Nachbesserungsrunden erlaubt. Danach anhalten und Nico informieren.
  Nach dem fünften Versuch ist die Annahme zu prüfen, ob das *Kriterium*
  falsch ist, nicht der Code.
- **CI ist Pflicht, nicht Beweis.** Grüne CI ist Mindestbedingung, ersetzt aber
  nie ein Akzeptanzkriterium und nie den menschlichen Build.

## 3. Verhalten bei Blockern

Ein echter Blocker ist ein Problem, das nach ernsthaftem Versuch nicht
selbst lösbar ist.

1. Anhalten.
2. Das Problem aus mindestens drei verschiedenen Blickwinkeln neu angehen
   (anderer Ansatz, anderer Layer, Umgehung, Reduktion des Umfangs).
3. Bleibt es ungelöst: Lauf pausieren, Nico informieren mit
   Problembeschreibung, den geprüften Wegen und einer Empfehlung.
4. **Nicht überspringen.** Ein übersprungenes Teilstück gilt als stiller
   Blocker und ist verboten.
5. Währenddessen an **unabhängigen** Blockteilen weiterarbeiten, sofern
   welche existieren und nicht auf dem Blocker aufbauen.

## 4. Die drei Stopps

An jedem Stopp spielt Nico selbst einen Debug-Build auf dem Mac. Der Loop
liefert dazu: Kurzbericht, abgehakte Kriterien, Build-Anleitung, und eine
Liste konkreter Fragen, auf die er beim Spielen achten soll.

| Stopp | Nach Block | Prüffrage |
|---|---|---|
| 1 | Block 2 (Run-Struktur) | Trägt der Kern-Loop über einen ganzen Run? |
| 2 | Block 4 (UI/Art/Audio) | Fühlt es sich wie ein Spiel an, nicht wie ein Prototyp? |
| 3 | Block 6 (iOS-Vorbereitung) | Läuft es sauber auf dem Gerät, einreichungsreif? |

**Während eines Stopps steht der Loop nicht still.** Er arbeitet an
Teilstücken weiter, die nachweislich unabhängig vom Feedback sind
(Tests, Doku, Refactorings, Tooling). Alles, was sich durch Nicos Feedback
ändern könnte, bleibt liegen.

Nicos Feedback kann jederzeit eintreffen, auch mitten in einem laufenden
Block. Es wird als eigener Fix-Task eingeplant, nicht ignoriert bis zum
Blockende.

## 5. Blockschnitt

Blöcke werden so geschnitten, dass **alle paar Tage ein spielbarer Build**
möglich ist. Ein Block, der länger als das ohne spielbares Ergebnis läuft,
wird geteilt.

### Block 1 — Lokalisierung (Vorbedingung, vor allen Texten)
Zuerst: Blueprint und Serien-Handbuch auf Lokalisierung prüfen. Falls
Zweisprachigkeit dort nicht vorgesehen ist, wird sie hier ergänzt und die
Abweichung nach Abschnitt 6 dokumentiert.
Danach: i18n-System (Godot-Translations), alle vorhandenen Texte als Keys,
Deutsch und Englisch vollständig gepflegt, Sprachumschaltung im Spiel.
Ab hier gilt: **kein neuer Text ohne Key in beiden Sprachen.**

### Block 2 — Phase 3: Run-Struktur
Pfadkarte/Knoten-Graph, Akt-Übergänge, Einwinterungs-Bewertung, Ereignisse,
Tausch, Relikte, Meta-Save und Replay.
→ **STOPP 1**

### Block 3 — Phase 4: Balancing und Vollcontent
Vollständiger Kartensatz, Bedrohungen aller drei Akte, Zahlenbalance,
Varroa-Kurve über den ganzen Run.

### Block 4 — UI, Art-Pass, Audio
Echte Oberfläche statt Greybox, Lesbarkeit, Feedback-Animationen, Sound.
→ **STOPP 2**

### Block 5 — Premium, Systeme, Politur
Demo-Grenze und Einmal-Unlock-IAP, Einstellungen, Barrierefreiheit,
Performance, Fehlerbehandlung, Speicherstände.

### Block 6 — iOS-Vorbereitung
Export-Preset, App-Icons, Launch-Screen, Bundle-ID, Berechtigungen,
Privacy-Manifest, alles bis zur Xcode-Grenze.
→ **STOPP 3**

### Block 7 — Store-Assets
Store-Texte Deutsch und Englisch, Screenshots, Vorschaubilder,
Datenschutzerklärung, App-Privacy-Angaben, Altersfreigabe, Keywords.
Bewusst am Ende, damit Screenshots die endgültige Optik zeigen.

## 6. Blueprint-Abweichungen

Der Blueprint darf angepasst werden, wenn sich beim Bauen zeigt, dass etwas
nicht funktioniert. Jede Abweichung wird:

1. in `docs/adr/` als kurzer Eintrag festgehalten (Was, Warum, Alternative),
2. im Blockbericht ausdrücklich genannt, nicht nur nebenbei erwähnt.

**Ausnahme Android:** Die Plattform-Reihenfolge ist auf Apple zuerst geändert.
Android wird **nicht** aus dem Blueprint entfernt, sondern bleibt als
späterer Pfad erhalten. Keine Entscheidung darf Android dauerhaft verbauen.

## 7. Offen und außerhalb des Loops

Das Spaß-Gate (≥10 Tester, ADR-0002) ist vorbereitet, aber nicht entschieden.
Der Loop wartet nicht darauf und baut weiter. Er hält die Gate-Materialien
aktuell, sodass Nico das Gate jederzeit starten kann. Ein Kill- oder
Rework-Entscheid überschreibt diesen Loop.

## 8. Berichtsformat am Blockende

- Was gebaut wurde
- Akzeptanzkriterien, einzeln abgehakt
- Abweichungen vom Blueprint
- Was ungeprüft blieb (ehrliche Prüf-Grenze)
- Nächster Block, der automatisch gezogen wird
