# Spaß-Gate — Debug-Build-Anleitung (für den Menschen)

Ziel: die Greybox auf ein Gerät bringen, das der Tester bedienen kann. Zwei Wege — Desktop reicht für viele Tester, Android ist näher am Zielprodukt.

> Voraussetzung: Godot **4.5-stable** lokal installiert (siehe ADR-0001; Version final pinnen). Repo geklont, `main_scene` = `res://ui/Greybox.tscn`.

## Weg A — Desktop (schnellster Test)
1. Godot öffnen → Projekt importieren (`project.godot`).
2. **F5** (Projekt starten). Die Greybox läuft im Fenster.
3. Bedienung: Karten-Buttons = Karte spielen · „Zug beenden" · „Neuer Run". Zustandsleiste oben zeigt Stärke/Vorrat/Varroa (+Druck)/Energie/Wächter/Zug.

## Weg B — Android-Debug-APK (näher am Zielgerät)
1. Godot: **Editor → Verwalten der Export-Vorlagen** → Vorlagen für 4.5 laden.
2. **Projekt → Exportieren → Android** (Preset anlegen). Debug-Keystore nutzt Godot automatisch für Debug-Builds.
3. **SDK/JDK:** exakt der Godot-Doku für 4.5 folgen (Android SDK, JDK-Version). *Stolperfalle laut Serien-Handbuch §2 — nichts mischen.*
4. „Exportieren (Debug)" → `.apk` aufs Testgerät kopieren, installieren (Quellen aus unbekannten Quellen erlauben).

## Testablauf
1. Pro Tester: `docs/gate/testerbogen.md` ausdrucken/kopieren.
2. Moderationsregeln beachten (kein Strategie-Tipp).
3. Nach ≥10 Testern: Kriterien aus `docs/gate/kill-kriterien.md` auswerten → **ADR-0002** anlegen (Go/Rework/Kill).

## Ehrliche Grenze
- Die Greybox nutzt einen **rohen** Sammlerin-Kartensatz (~13 Karten, 1 Akt-1-Bedrohung) — Balancing folgt in Phase 4. Es geht **nur** um die Frage „trägt der Kern?".
- Die UI ist absichtlich hässlich. Der headless Kern ist per CI (60+ Tests) verifiziert; die **UI-Darstellung** ist bis zu diesem Build durch nichts geprüft — dein Testlauf ist ihr erster echter Check.
