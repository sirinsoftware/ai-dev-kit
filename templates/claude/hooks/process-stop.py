#!/usr/bin/env python3
"""ai-dev-kit delivery-process stop gate (Stop hook).

Refuses to end a session on a red build DURING process work. Reads the state file
written by /execute and /verify-feature (docs/process/<branch>/.verify-state.json,
{"tests": "green"|"red", ...}) — it never runs tests itself, so it is cheap on every
Stop. Inert when: no state file for the current branch, tests are green,
stop_hook_active is set (loop guard), or ADK_PROCESS_OFF=1. Fail-open on any error.
"""
import json
import os
import subprocess
import sys


def main():
    if os.environ.get("ADK_PROCESS_OFF") == "1":
        sys.exit(0)
    try:
        data = json.load(sys.stdin)
    except (ValueError, OSError):
        sys.exit(0)
    if data.get("stop_hook_active"):
        sys.exit(0)              # already continuing because of this hook — never loop
    cwd = data.get("cwd") or os.getcwd()
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
    state_path = os.path.join(cwd, "docs", "process", branch, ".verify-state.json")
    try:
        with open(state_path, encoding="utf-8") as f:
            state = json.load(f)
    except (OSError, ValueError):
        sys.exit(0)              # no state -> not in process work -> inert
    if not isinstance(state, dict) or state.get("tests") != "red":
        sys.exit(0)
    sys.stderr.write(
        "[ai-dev-kit process] Tests are RED for '" + branch + "' per "
        "docs/process/" + branch + "/.verify-state.json — don't stop on a red build. "
        "Fix the failures (or record the honest state in verify.md); update the state "
        "file to \"green\" after a passing run. Escape hatch: ADK_PROCESS_OFF=1.\n"
    )
    sys.exit(2)


if __name__ == "__main__":
    main()
