# Beutenjahr

**Imkerei-Deckbuilder-Roguelite** — führe ein Bienenvolk durch ein Trachtjahr in drei Akten. Varroa ist der eskalierende Dauergegner.

- **Engine:** Godot 4.5 + GDScript (Android-first, iOS nachgelagert)
- **Modell:** Free Demo (Akt 1 + 1 Archetyp) + einmaliger Unlock-IAP · voll offline · keine Werbung, keine Accounts
- **Architektur:** deterministischer, headless Sim-Kern (`core/`) · datengetriebener Content (JSON) · UI ist reiner Konsument

## Für Entwickler

| Was | Wo |
|---|---|
| Nächster Schritt | [`NEXT.md`](NEXT.md) |
| Fortschritt & Risiken | [`FORTSCHRITT.md`](FORTSCHRITT.md) |
| Offene Mensch-Aufgaben | [`MENSCH-TODO.md`](MENSCH-TODO.md) |
| Entscheidungen | [`docs/decisions/`](docs/decisions/) |
| Content-Schema | [`docs/content-schema.md`](docs/content-schema.md) |

### Lokale Werkzeuge

```bash
# GDScript-Linting (ohne Godot lauffähig)
pip install "gdtoolkit==4.*"
gdlint core/ ui/ tests/

# Content-JSON gegen Schema prüfen
python3 tools/validate_content.py
```

Tests laufen headless über Godot (`godot --headless`) — siehe [`docs/decisions/ADR-0001-stack.md`](docs/decisions/ADR-0001-stack.md) und die CI unter `.github/workflows/`.

> Quelldokumente (Blueprint, Serien-Handbuch) liegen außerhalb des Repos beim Auftraggeber. Dieses Repo ist die Umsetzung.
