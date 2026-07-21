#!/usr/bin/env python3
"""Validiert alle Content-JSONs gegen die Schemata + Semantikregeln (AP 0.3).

Laeuft lokal (ohne Godot) und in CI. Exit-Code != 0 bei jedem Fehler.
Regel (CLAUDE.md): Kein Content-Objekt wird committet, das nicht maschinell
validiert ist.
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

from jsonschema import Draft202012Validator
from referencing import Registry, Resource

ROOT = Path(__file__).resolve().parent.parent
CONTENT = ROOT / "content"
SCHEMA_DIR = CONTENT / "schema"

# type-Verzeichnis -> Schemadatei
TYPES = {
    "cards": "card.schema.json",
    "threats": "threat.schema.json",
    "events": "event.schema.json",
    "relics": "relic.schema.json",
}

# Ops, die dauerhaften Volkszustand aendern und daher ausserhalb von
# Begegnungen (Ereignisse, Run-Trigger) erlaubt sind. Siehe content-schema.md §2.
PERS_OPS = {
    "heal", "gain_stores", "spend_stores", "add_varroa", "reduce_varroa",
    "generate_card", "convert", "custom_effect",
}

# Op -> zusaetzlich erforderliche Felder (Semantik, die das JSON-Schema
# bewusst nicht per if/then erzwingt).
OP_REQUIRED_FIELDS = {
    "custom_effect": ["hook"],
    "convert": ["from", "to", "ratio"],
    "generate_card": ["card_id"],
    "apply_status": ["status"],
    "remove_status": ["status"],
    "scale_per_turn": ["status"],
}

errors: list[str] = []


def err(where: str, msg: str) -> None:
    errors.append(f"{where}: {msg}")


def load_registry() -> Registry:
    resources = []
    for path in sorted(SCHEMA_DIR.glob("*.schema.json")):
        schema = json.loads(path.read_text(encoding="utf-8"))
        resources.append((path.name, Resource.from_contents(schema)))
    return Registry().with_resources(resources)


def iter_effects(obj):
    """Rekursiv alle Effekt-Objekte (mit 'op') aus einem Content-Objekt ziehen."""
    if isinstance(obj, dict):
        if "op" in obj and isinstance(obj.get("op"), str):
            yield obj
        for value in obj.values():
            yield from iter_effects(value)
    elif isinstance(obj, list):
        for item in obj:
            yield from iter_effects(item)


def check_effect_semantics(where: str, effect: dict, is_event: bool) -> None:
    op = effect.get("op")
    for field in OP_REQUIRED_FIELDS.get(op, []):
        if field not in effect:
            err(where, f"op '{op}' braucht Feld '{field}'")
    if op == "convert" and effect.get("from") == effect.get("to"):
        err(where, "convert: 'from' und 'to' duerfen nicht gleich sein")
    if is_event and op not in PERS_OPS:
        err(where, f"Ereignis-Effekt nutzt Begegnungs-Op '{op}' (nur pers-Ops erlaubt)")


def main() -> int:
    if not CONTENT.exists():
        print("FEHLER: content/ nicht gefunden", file=sys.stderr)
        return 2

    registry = load_registry()
    validators = {
        name: Draft202012Validator(
            json.loads((SCHEMA_DIR / schema_file).read_text(encoding="utf-8")),
            registry=registry,
        )
        for name, schema_file in TYPES.items()
    }

    ids_by_type: dict[str, set[str]] = {t: set() for t in TYPES}
    generate_refs: list[tuple[str, str]] = []
    total = 0

    for type_name in TYPES:
        type_dir = CONTENT / type_name
        if not type_dir.exists():
            continue
        for path in sorted(type_dir.glob("*.json")):
            total += 1
            rel = path.relative_to(ROOT)
            try:
                data = json.loads(path.read_text(encoding="utf-8"))
            except json.JSONDecodeError as exc:
                err(str(rel), f"ungueltiges JSON: {exc}")
                continue

            # 1. Schema
            schema_errors = sorted(
                validators[type_name].iter_errors(data), key=lambda e: e.path
            )
            for e in schema_errors:
                loc = "/".join(str(p) for p in e.path) or "(wurzel)"
                err(str(rel), f"[{loc}] {e.message}")

            # 2. Datei-ID == deklarierte ID, Eindeutigkeit
            declared = data.get("id")
            if declared != path.stem:
                err(str(rel), f"id '{declared}' != Dateiname '{path.stem}'")
            if declared in ids_by_type[type_name]:
                err(str(rel), f"doppelte id '{declared}'")
            ids_by_type[type_name].add(declared)

            # 3. Effekt-Semantik
            is_event = type_name == "events"
            for effect in iter_effects(data):
                check_effect_semantics(str(rel), effect, is_event)
                if effect.get("op") == "generate_card" and "card_id" in effect:
                    generate_refs.append((str(rel), effect["card_id"]))

    # 4. Referenzintegritaet: generate_card.card_id -> existierende Karte
    known_cards = ids_by_type["cards"]
    for rel, card_id in generate_refs:
        if card_id not in known_cards:
            err(rel, f"generate_card verweist auf unbekannte Karte '{card_id}'")

    print(f"Geprueft: {total} Content-Objekte "
          f"({', '.join(f'{len(ids_by_type[t])} {t}' for t in TYPES)}).")
    if errors:
        print(f"\n{len(errors)} FEHLER:", file=sys.stderr)
        for e in errors:
            print(f"  - {e}", file=sys.stderr)
        return 1
    print("Alle Content-Objekte valide.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
