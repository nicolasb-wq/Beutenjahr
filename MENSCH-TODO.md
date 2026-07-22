# MENSCH-TODO — nur ein Mensch kann das erledigen

Diese Liste ist die ehrliche Grenze der autonomen Entwicklung. Solange hier offene Punkte stehen, ist das Spiel **nicht verkaufsfertig** — egal wie grün die CI ist. Die Liste wird laufend präzisiert, nie beschönigt.

Legende: 🔴 Blocker für Release · 🟡 wichtig, terminiert · ⚪ optional/später

---

## Sofort relevant (Setup-Realität)

- 🟡 **Godot-Version final pinnen.** Aktuelle stable-Patch-Version (vermutlich 4.5.x) auf deiner Maschine feststellen; `project.godot` (`config/features`) und die CI-Godot-Version gleichziehen. Nie dev/rc. *(Grund: in der Cloud-Umgebung nicht installierbar — Version nur aus gdtoolkit-Signal abgeleitet, ADR-0001.)*
- 🟡 **Erster Android-Export (AP 0.2 DoD).** Godot-Android-Exportvorlagen + Debug-Keystore einrichten, leere Szene aufs eigene Handy exportieren. *Der erste Mobile-Export ist erfahrungsgemäß der schmerzhafteste — früh tun.*
- 🟡 **Test-Harness gegenprüfen.** Sobald Godot lokal läuft: bestätigen, dass der eigene Headless-Test-Runner sauber durchläuft; sonst auf GUT migrieren (ADR-0001, Fallback).

## Gates (Investitionsschutz)

- 🔴 **Spaß-Gate (Blueprint Phase 2, AP 2.2) — VORBEREITET, wartet auf dich.** Externer Test mit **≥10 Testern**. Alles Nötige liegt bereit:
  - Greybox spielbar (`ui/Greybox.tscn`, `main_scene` gesetzt; roher Sammlerin-Satz + Akt-1-Bedrohung).
  - **Debug-Build-Anleitung:** `docs/gate/debug-build-anleitung.md` (Desktop-F5 oder Android-Debug-APK).
  - **Testerbogen:** `docs/gate/testerbogen.md` · **Kill-Kriterien (vorab fix):** `docs/gate/kill-kriterien.md`.
  - **Dein Schritt:** ≥10 Tester, dann Kriterien auswerten und **ADR-0002 (Go/Rework/Kill)** anlegen. Kill ist ein Erfolg des Systems.
- 🔴 **Balancing-Beta (AP 8.2).** 20–30 Tester über Play-Testtrack, 3–4 Kalenderwochen. Kriterien: menschliche Winrate Stufe 0 im Korridor 25–45 %; ≥50 % spielen ≥5 Runs; Varroa von ≥8/10 als „fordernd, aber fair"; 0 bekannte Crashes.

## Echtgeräte (Serien-Handbuch §4, AP 8.1)

- 🔴 **Gerätematrix:** Hauptgerät + 1 Billig-Android (≤80 €) + 1 großes Gerät/Tablet (+ ältestes iPhone, falls iOS).
- 🔴 **Testprotokoll:** Kaltstart, App-Kill mitten in der Kartenaktion (Save intakt?), Anruf-Unterbrechung, Rotation, 45-Min-Akku/Thermik, Flugmodus. Zusätzlich: Kartentext-Lesbarkeit auf kleinem Display.

## Store & Recht (Serien-Handbuch §3.3, §5, §6)

- 🔴 **Google-Play-Konto** (Gebühr *Glaube ich* ~25 USD einmalig — prüfen) inkl. aktueller Verifizierungs-/Testerpflichten neuer Konten (beeinflusst Beta-Planung!).
- ⚪ **Apple Developer Program** (*Glaube ich* ~99 USD/Jahr — prüfen), falls iOS im Erstlaunch.
- 🔴 **Echtes IAP-Produkt** anlegen + Testkauf + Restore auf Zweitgerät verifizieren. Godot-IAP-Plugin (Play Billing) recherchieren (Serien-Handbuch §3.1/§7, R2) — ich implementiere nur `StoreService` + `FakeStore`.
- 🔴 **Release-Keystore** erzeugen und **3× sichern** (Passwort-Manager + 2 Offline-Kopien). Verlust = App-Identität für immer weg. Play App Signing aktivieren.
- 🔴 **Datenschutz-URL** live (statische Seite, „keine Datenerhebung"). Data-Safety/App-Privacy wahrheitsgemäß.
- 🔴 **Impressum/Anbieterkennzeichnung + Nebengewerbe/Steuern** klären (Steuerberater; ggf. Ausbildungsbetrieb/Nebentätigkeitsklausel).
- 🔴 **IARC-/Apple-Altersfragebogen** ausfüllen (erwartbar „ab 0").
- 🔴 **Namensprüfung final:** DPMA-Markenrecherche + Store-Namensprüfung „Beutenjahr" (DE) und EN-Titel-Kollisionscheck. *(Web-Vorabcheck ohne Kollision — kein Ersatz für die Rechtsprüfung, R6.)*
- 🔴 **Marktcheck final:** Google Play / App Store / Steam / itch.io direkt auf einen Bienen-Deckbuilder sichten (R3; Web-Vorabcheck ist US-zentriert).

## Content / Fachlichkeit

- 🟡 **Kompendium-Fachreview** durch 1–2 Imker-Vereinskollegen (R4). Spielvereinfachungen sind im Kompendium zu kennzeichnen.
- ⚪ **Finale Audio-Eigenaufnahmen** am Bienenstand (ersetzt Platzhalter-Sounds; Marketing-Story).

## Launch (AP 10.1)

- 🟡 **Creator-Keyliste (~30)** + persönliche Zeilen + Embargo-Datum; 2 Wochen vor Launch verschicken.
- 🟡 **Imker-Ökosystem:** Vereins-Newsletter, Forum-Post, Pressenotiz an 2–3 Fachmagazine.
- 🔴 **Einreichung mit gestaffeltem Rollout** (20 % → 100 %).

---

> **Wiederhol-Prüfaufträge (Serien-Handbuch §7):** R2 (IAP-Plugins produktionsreif?), R3 (Small-Business-Gebühren beider Stores aktuell, *Glaube ich* 15 %?), S1 (Auszahlungsformel nach ~50 echten Verkäufen gegen Store-Abrechnung eichen).
