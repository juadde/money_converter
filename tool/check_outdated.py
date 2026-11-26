#!/usr/bin/env python3
"""Fails when a Dart package is not at its newest usable version.

Reads the output of `flutter pub outdated --json` (file given as argument)
and reports:
- a direct or dev dependency below the newest version the dependency tree
  allows (the "Resolvable" column): raise its constraint in pubspec.yaml;
- any package that is discontinued or whose version in use was retracted.

A newer "Latest" version that nothing can use yet (usually because the
Flutter SDK pins the package) is only listed, as a notice.

Usage: flutter pub outdated --json > outdated.json
       python3 tool/check_outdated.py outdated.json
"""

import json
import sys


def version(package, column):
    return (package.get(column) or {}).get("version")


def main(path):
    data = json.load(open(path, encoding="utf-8"))
    problems, notices = [], []
    for package in data.get("packages", []):
        name, kind = package["package"], package.get("kind", "?")
        current = version(package, "current")
        resolvable = version(package, "resolvable")
        latest = version(package, "latest")
        if package.get("isDiscontinued"):
            replaced = package.get("discontinuedReplacedBy")
            problems.append(f"{name} is discontinued"
                            + (f", replaced by {replaced}" if replaced else ""))
        if package.get("isCurrentRetracted"):
            problems.append(f"{name} {current} was retracted by its author")
        if current is None:
            continue
        if resolvable and current != resolvable:
            if kind in ("direct", "dev"):
                problems.append(f"{name} ({kind}): {current} in use, {resolvable} "
                                "available: raise its constraint in pubspec.yaml")
            else:
                problems.append(f"{name} (transitive): {current} in use, "
                                f"{resolvable} possible")
        elif latest and current != latest:
            notices.append(f"{name} ({kind}): {latest} published, {current} is the "
                           "newest the dependency tree allows")

    for line in notices:
        print(f"::notice::{line}")
    for line in problems:
        print(f"::error::{line}")
    if problems:
        print(f"{len(problems)} package(s) not up to date (see flutter pub outdated).")
        return 1
    print("All Dart packages are at their newest usable version.")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1]))
