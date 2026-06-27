#!/usr/bin/env python3
"""Merge ai-dev-kit's guardrail hooks into an existing .claude/settings.json.

Adds PreToolUse hooks pointing at the kit's guard scripts, without disturbing
other settings. Idempotent: re-running replaces the kit's hook entries only
(matched by the guard-script command path), leaving any user hooks intact.

Usage: hooks_merge.py <path-to-.claude/settings.json>
"""
import json
import os
import sys

GUARD = "$CLAUDE_PROJECT_DIR/.claude/hooks"
ENTRIES = [
    {"matcher": "Bash",
     "hooks": [{"type": "command", "command": f"{GUARD}/guard-bash.py"}]},
    {"matcher": "Read|Edit|Write|MultiEdit",
     "hooks": [{"type": "command", "command": f"{GUARD}/guard-paths.py"}]},
]


def is_kit_entry(entry):
    for h in entry.get("hooks", []):
        if isinstance(h, dict) and GUARD in str(h.get("command", "")):
            return True
    return False


def main():
    path = sys.argv[1]
    data = {}
    if os.path.exists(path) and os.path.getsize(path) > 0:
        try:
            with open(path, encoding="utf-8") as f:
                data = json.load(f)
        except (ValueError, OSError):
            data = {}
    if not isinstance(data, dict):
        data = {}

    hooks = data.get("hooks")
    if not isinstance(hooks, dict):
        hooks = {}
    pre = hooks.get("PreToolUse")
    if not isinstance(pre, list):
        pre = []
    # drop any prior kit entries, then add ours back (idempotent)
    pre = [e for e in pre if not is_kit_entry(e)]
    pre.extend(ENTRIES)
    hooks["PreToolUse"] = pre
    data["hooks"] = hooks

    os.makedirs(os.path.dirname(path) or ".", exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2)
        f.write("\n")


if __name__ == "__main__":
    main()
