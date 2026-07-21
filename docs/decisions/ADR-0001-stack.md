# ADR-0001 — Technischer Stack

- **Status:** Akzeptiert
- **Datum:** 2026-07-21
- **Bezug:** Serien-Handbuch §1.1/§2, Blueprint Abschnitt 7, `CLAUDE.md` (Technische Leitplanken)

## Entscheidung

| Baustein | Wahl | Konfidenz |
|---|---|---|
| Engine | **Godot 4.5** (stable-Linie), Renderer „mobile" | Glaube ich (siehe unten) |
| Sprache | **GDScript**, keine C#-/.NET-Abhängigkeit | Bestätigt (Serien-Standard) |
| Test-Ausführung | headless über `godot --headless` | Bestätigt |
| Test-Harness | **eigener minimaler GDScript-Runner** (`tests/`) statt GUT/gdUnit4 | bewusste Abweichung, s. u. |
| Content | datengetriebenes JSON + Effekt-Interpreter | Bestätigt (Blueprint 7.2) |
| Saves | lokal, atomar (Temp+Rename), `schemaVersion` ab Save 1 | Bestätigt |
| Lint/Format | `gdtoolkit` (`gdlint`/`gdformat`), Version 4.5 | Bestätigt (lokal verifiziert: 4.5.0 läuft) |

## Godot-Version — Begründung & Prüfauftrag

Godot ließ sich in dieser Cloud-Umgebung **nicht** installieren (Release-Download von github.com per Egress-Policy geblockt, HTTP 403 — nicht umgangen). Die Versionswahl stützt sich daher auf ein indirektes Signal: `gdtoolkit` 4.5.0 (das die GDScript-Grammatik von Godot-Releases nachbildet) ließ sich installieren und läuft. Das legt nahe, dass **4.5 die aktuelle stable-Linie** ist.

- **Prüfauftrag (MENSCH-TODO):** exakte aktuelle stable-Patch-Version (z. B. 4.5.x) auf der Menschen-Maschine festnageln, `project.godot` (`config/features`) und die CI-Godot-Version danach gleichziehen. **Nie eine dev-/rc-Version** verwenden (Serien-Handbuch §2.1).

## Test-Harness — Abweichung von „GUT oder gdUnit4"

Der Blueprint/`CLAUDE.md` empfiehlt GUT oder gdUnit4. Wir weichen bewusst ab und schreiben einen **schlanken, projekteigenen Headless-Runner** (`tests/test_runner.gd` + `tests/test_case.gd`).

**Begründung:**
1. **Umgebungs-Realität:** Externe Addons lassen sich hier nicht herunterladen/verifizieren (gleiche 403-Sperre). Ein selbst geschriebener Runner ist sofort lauffähig und braucht keinen Addon-Fetch-Schritt in CI.
2. **Kern ist test-freundlich:** Der Sim-Kern ist reine Integer-Arithmetik mit seeded RNG — Assert-artige Checks genügen; ein schweres Framework bringt wenig Mehrwert.
3. **Reproduzierbarkeit:** Keine Submodule/Addon-Version als versteckte Variable; die CI bleibt selbstenthalten.
4. **Determinismus-Kontrolle:** Doppellauf-Vergleich (bitidentische Zustände) und Seed-Handling steuern wir direkt.

**Fallback (dokumentiert):** Wird der eigene Runner limitierend (parametrisierte Suites, Mocking, Reporting), migrieren wir auf **GUT** (einfachste Headless-CLI) — dann als neuer ADR. Die Testfälle werden so geschrieben, dass eine spätere Migration mechanisch bleibt (klare `assert_*`-Fassade).

## Verifikations-Realität dieser Umgebung (wichtig, ehrlich)

Da Godot hier nicht läuft, gilt für alle in dieser Cloud-Umgebung erzeugten Commits:

- **Lokal verifizierbar:** GDScript-Syntax/-Stil via `gdlint`; Content-JSON gegen JSON-Schema via Python.
- **Nur in CI / auf Menschen-Maschine verifizierbar:** tatsächlicher Godot-Lauf, Unit-Tests, Determinismus-Doppellauf, Autoplayer.
- **Konsequenz:** GitHub-Actions-CI ist die maßgebliche Verifikationsschleife. „CI grün" ist Release-Bedingung (Serien-Handbuch §1.4). Ein Commit gilt erst als verifiziert, wenn die CI ihn bestätigt hat.

## Architektur-Leitplanken (aus Blueprint 7.2, hier fixiert)

- `core/` ist **strikt headless**: reine Funktionen, Integer, **kein Node-Zugriff**, keine `randi()`-Aufrufe außerhalb der Seed-Ströme.
- **Getrennte, seeded RNG-Ströme** je Subsystem: `deck`, `threat`, `event`, `map` — verhindert, dass eine zusätzliche Ziehung alle Replays verschiebt.
- UI (`ui/`) ist reiner Konsument eines vorausberechneten Zustands/Tick-Protokolls.

## Alternativen erwogen

- **C#/.NET:** verworfen — iOS-Export-Reife unsicher (Serien-Standard).
- **GUT/gdUnit4 sofort:** verworfen für den Bootstrap (nicht herunterladbar); bleibt dokumentierter Fallback.
- **Godot 4.4 statt 4.5:** möglich; 4.5 gewählt wegen des gdtoolkit-Signals. Menschliche Prüfung pinnt final.
