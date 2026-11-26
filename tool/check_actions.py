#!/usr/bin/env python3
"""Fails when a workflow uses an older major version of a GitHub Action.

Every `uses: owner/repo[/path]@vN` of .github/workflows is compared with
the newest major tag (vN) of the action's repository, read with
`git ls-remote` (no token needed for public actions). Dependabot opens the
update pull requests; this check makes the build say so in the meantime.
"""

import pathlib
import re
import subprocess
import sys

USES = re.compile(r"^\s*-?\s*uses:\s*([\w.-]+/[\w.-]+)(?:/[\w./-]+)?@(\S+)", re.M)


def newest_major(repo):
    out = subprocess.run(
        ["git", "ls-remote", "--tags", f"https://github.com/{repo}"],
        capture_output=True, text=True, check=True, timeout=60).stdout
    majors = {int(m) for m in re.findall(r"refs/tags/v(\d+)(?:\.\d+)*(?:\^\{\})?$", out, re.M)}
    return max(majors) if majors else None


def main():
    used = {}
    for workflow in sorted(pathlib.Path(".github/workflows").glob("*.y*ml")):
        for repo, ref in USES.findall(workflow.read_text(encoding="utf-8")):
            used.setdefault((repo, ref), []).append(workflow.name)
    problems = 0
    for (repo, ref), files in sorted(used.items()):
        match = re.fullmatch(r"v(\d+)(?:\.\d+)*", ref)
        if not match:
            print(f"::notice::{repo}@{ref} is not a version tag, not checked")
            continue
        latest = newest_major(repo)
        if latest is not None and int(match.group(1)) < latest:
            problems += 1
            print(f"::error::{repo}@{ref} in {', '.join(files)}: v{latest} is available")
        else:
            print(f"{repo}@{ref}: up to date")
    if problems:
        print(f"{problems} action(s) not up to date.")
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main())
