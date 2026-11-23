#!/usr/bin/env python3
"""Checks the Google Play listing texts against the store limits.

Usage: python3 tool/check_store_metadata.py [fastlane/metadata/android]
"""

import pathlib
import sys

LIMITS = {
    "title.txt": 30,
    "short_description.txt": 80,
    "full_description.txt": 4000,
    "changelogs/default.txt": 500,
}
LOCALES = ["en-US", "fr-FR", "de-DE", "es-ES", "it-IT", "pl-PL", "ro", "lt"]


def main():
    base = pathlib.Path(sys.argv[1] if len(sys.argv) > 1 else "fastlane/metadata/android")
    errors = []
    for locale in LOCALES:
        for name, limit in LIMITS.items():
            path = base / locale / name
            if not path.is_file():
                errors.append(f"{path}: missing")
                continue
            text = path.read_text(encoding="utf-8").strip()
            if not text:
                errors.append(f"{path}: empty")
            elif len(text) > limit:
                errors.append(f"{path}: {len(text)} characters, limit {limit}")
        for image in ("images/icon.png", "images/featureGraphic.png"):
            if not (base / locale / image).is_file():
                errors.append(f"{base / locale / image}: missing")
    if errors:
        sys.exit("\n".join(errors))
    print(f"Store listing OK for {len(LOCALES)} languages")


if __name__ == "__main__":
    main()
