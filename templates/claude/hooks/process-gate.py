#!/usr/bin/env python3
"""ai-dev-kit delivery-process gate (PreToolUse on Edit/Write/MultiEdit).

Blocks PRODUCTION-code edits on a feature branch whose plan has not been defended
(docs/process/<branch>/defense.md missing "Verdict: READY"). Inert everywhere else:
 - no docs/process/<current branch>/ directory  -> allow (repo/branch not using the process)
 - the edited file is under docs/ (process artifacts, guides) -> allow
 - ADK_PROCESS_OFF=1                            -> allow (escape hatch)
Fail-open by design: any unexpected error allows the edit.
"""
import json
import os
import re
import subprocess
import sys


def main():
    if os.environ.get("ADK_PROCESS_OFF") == "1":
        sys.exit(0)
    try:
        data = json.load(sys.stdin)
    except (ValueError, OSError):
        sys.exit(0)
    cwd = data.get("cwd") or os.getcwd()
    path = ((data.get("tool_input") or {}).get("file_path") or "")
    if not path:
        sys.exit(0)
    rel = os.path.relpath(path, cwd) if os.path.isabs(path) else path
    # Docs (including docs/process/ artifacts) are always editable.
    if rel.startswith("docs" + os.sep) or rel in ("docs",):
        sys.exit(0)
    try:
        # --show-current (not rev-parse): works on an unborn branch (no commits yet).
        branch = subprocess.run(
            ["git", "branch", "--show-current"],
            cwd=cwd, capture_output=True, text=True, timeout=5,
        ).stdout.strip()
    except Exception:
        sys.exit(0)
    if not branch:
        sys.exit(0)              # detached HEAD or not a git repo -> inert
    proc_dir = os.path.join(cwd, "docs", "process", branch)
    if not os.path.isdir(proc_dir):
        sys.exit(0)              # this branch is not a process feature -> inert
    defense = os.path.join(proc_dir, "defense.md")
    try:
        with open(defense, encoding="utf-8") as f:
            if re.search(r"^Verdict:\s*READY\s*$", f.read(), re.M):
                sys.exit(0)      # defended -> allow
    except OSError:
        pass                     # missing defense.md -> block below
    sys.stderr.write(
        "[ai-dev-kit process] Blocked: branch '" + branch + "' has a delivery-process "
        "dir (docs/process/" + branch + "/) but no defended plan (defense.md with "
        "'Verdict: READY').\nRun /defend " + branch + " (or /prepare) first, or set "
        "ADK_PROCESS_OFF=1 to bypass.\n"
    )
    sys.exit(2)


if __name__ == "__main__":
    main()
