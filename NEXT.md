# NEXT — der eine nächste Schritt

## Jetzt: **STOPP 1** (LOOP §4) — Nico spielt

Block 2 (Run-Struktur) ist abgeschlossen, CI grün (83 Tests). Ein **ganzer Run** ist spielbar.
**Nico spielt einen Debug-Build** und beantwortet die Prüffrage: *Trägt der Kern-Loop über einen ganzen Run?*

→ Materialien: **`docs/stops/stopp-1.md`** (Kurzbericht, Build-Anleitung, konkrete Fragen).

**Block 3 wird bewusst NICHT automatisch gezogen** (LOOP: an einem Stopp hält der Loop für Feedback; er darf nur an feedback-**unabhängigen** Teilen weiterarbeiten — Tests, Doku, Tooling, Refactorings).

## Feedback-unabhängige Arbeit während des Stopps (erlaubt)
- Test-/Tooling-Verbesserungen, Doku, kleine Refactorings am Kern.
- **Nicht** anfangen: voller Kartensatz / Zahlenbalance (Block 3) und echte UI/Art (Block 4) — beide würden sich durch Nicos Feedback ändern.

## Danach (nach Nicos Go am Stopp)
- **Block 3 — Phase 4: Balancing & Vollcontent** (voller Kartensatz, Bedrohungen aller Akte, Zahlenbalance, Varroa-Kurve über den ganzen Run). Kriterien zuerst in `docs/blocks/block-3-*.md`.

> Godot lokal nicht ausführbar → CI ist die Verifikation. Vor jedem Push: `gdlint`/`gdformat`/`validate_content.py`/`validate_i18n.py` + Variant-Wächter grün.
