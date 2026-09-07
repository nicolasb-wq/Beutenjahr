#!/usr/bin/env python3
"""Validiert die Lokalisierung (Block 1, LOOP.md).

Prueft:
  1. de.json und en.json haben identische Schluesselmengen, keine Leerwerte.
  2. Jeder in content/*.json referenzierte Anzeige-Key (name_key/text_key/
     label_key, inkl. Intent-name_key) existiert in beiden Sprachen.
  3. Jeder von der UI statisch benoetigte Key (Loc.t("literal") in ui/*.gd)
     existiert in beiden Sprachen.

Ausgeschlossen (Scope-Grenze, docs/blocks/block-1-lokalisierung.md):
  kompendium_key (Phase 5) und core/GameLog-Zeilen (Entwickler-Diagnose).

Regel ab Block 1: kein neuer Text ohne Key in beiden Sprachen.
"""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
I18N = ROOT / "assets" / "i18n"
CONTENT = ROOT / "content"
UI = ROOT / "ui"

LOCALES = ["de", "en"]
DISPLAY_KEY_FIELDS = {"name_key", "text_key", "label_key"}

errors: list[str] = []


def err(msg: str) -> None:
    errors.append(msg)


def load_tables() -> dict[str, dict]:
    tables = {}
    for code in LOCALES:
        path = I18N / f"{code}.json"
        try:
            tables[code] = json.loads(path.read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError) as exc:
            err(f"{path.name}: nicht ladbar ({exc})")
            tables[code] = {}
    return tables


def collect_referenced_keys(obj, out: set[str]) -> None:
    if isinstance(obj, dict):
        for key, value in obj.items():
            if key in DISPLAY_KEY_FIELDS and isinstance(value, str):
                out.add(value)
            else:
                collect_referenced_keys(value, out)
    elif isinstance(obj, list):
        for item in obj:
            collect_referenced_keys(item, out)


def content_keys() -> set[str]:
    out: set[str] = set()
    for path in sorted(CONTENT.rglob("*.json")):
        if "schema" in path.parts:
            continue
        try:
            data = json.loads(path.read_text(encoding="utf-8"))
        except json.JSONDecodeError as exc:
            err(f"{path.relative_to(ROOT)}: ungueltiges JSON ({exc})")
            continue
        collect_referenced_keys(data, out)
    return out


def ui_keys() -> set[str]:
    out: set[str] = set()
    # Nur vollstaendige Literale: Loc.t("key") — nicht Loc.t("prefix." + var).
    pattern = re.compile(r'Loc\.t\(\s*"([a-z0-9_.]+)"\s*\)')
    for path in sorted(UI.rglob("*.gd")):
        for match in pattern.finditer(path.read_text(encoding="utf-8")):
            out.add(match.group(1))
    return out


def main() -> int:
    tables = load_tables()
    de, en = tables["de"], tables["en"]

    # 1. Paritaet + Leerwerte
    only_de = sorted(set(de) - set(en))
    only_en = sorted(set(en) - set(de))
    for k in only_de:
        err(f"Schluessel nur in de.json: '{k}'")
    for k in only_en:
        err(f"Schluessel nur in en.json: '{k}'")
    for code in LOCALES:
        for key, value in tables[code].items():
            if not isinstance(value, str) or value.strip() == "":
                err(f"{code}.json: leerer/ungueltiger Wert fuer '{key}'")

    # 2./3. referenzierte Keys vorhanden?
    referenced = content_keys() | ui_keys()
    for key in sorted(referenced):
        for code in LOCALES:
            if key not in tables[code]:
                err(f"referenzierter Key fehlt in {code}.json: '{key}'")

    print(
        "i18n geprueft: %d de / %d en Schluessel, %d referenzierte Keys "
        "(Content+UI)." % (len(de), len(en), len(referenced))
    )
    if errors:
        print(f"\n{len(errors)} FEHLER:", file=sys.stderr)
        for e in errors:
            print(f"  - {e}", file=sys.stderr)
        return 1
    print("Lokalisierung vollstaendig und paritaetisch.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
