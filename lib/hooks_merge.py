#!/usr/bin/env python3
"""Add or remove ai-dev-kit's hooks in a .claude/settings.json.

Idempotent and surgical: it only ever touches PreToolUse/Stop entries whose command
points at the kit's hook scripts — user hooks and other settings are preserved.

Usage:
  hooks_merge.py [--guards] [--process] <settings.json>   # add the selected hook sets
  hooks_merge.py --remove <settings.json>                 # strip ALL kit hooks (uninstall)

With no set flag, --guards is assumed (back-compat). Add mode is declarative:
kit entries are stripped first, then the requested sets are written.
"""
import json
import os
import shutil
import sys

GUARD = "$CLAUDE_PROJECT_DIR/.claude/hooks"
GUARD_ENTRIES = [
    {"matcher": "Bash",
     "hooks": [{"type": "command", "command": f"{GUARD}/guard-bash.py"}]},
    {"matcher": "Read|Edit|Write|MultiEdit",
     "hooks": [{"type": "command", "command": f"{GUARD}/guard-paths.py"}]},
]
PROCESS_PRE_ENTRIES = [
    {"matcher": "Edit|Write|MultiEdit",
     "hooks": [{"type": "command", "command": f"{GUARD}/process-gate.py"}]},
]
PROCESS_STOP_ENTRIES = [
    {"hooks": [{"type": "command", "command": f"{GUARD}/process-stop.py"}]},
]


def is_kit_entry(entry):
    if not isinstance(entry, dict):
        return False
    for h in entry.get("hooks", []):
        if isinstance(h, dict) and GUARD in str(h.get("command", "")):
            return True
    return False


def main():
    args = sys.argv[1:]
    remove = "--remove" in args
    want_guards = "--guards" in args
    want_process = "--process" in args
    positional = [a for a in args if not a.startswith("--")]
    if not positional:
        sys.exit("hooks_merge: missing settings.json path")
    path = positional[0]
    if not remove and not want_guards and not want_process:
        want_guards = True                      # back-compat default

    if not os.path.exists(path):
        if remove:
            sys.exit(0)            # nothing to strip
        data = {}
    else:
        try:
            with open(path, encoding="utf-8") as f:
                data = json.load(f)
        except (ValueError, OSError):
            data = None
        if not isinstance(data, dict):
            # Malformed or unexpected shape: never overwrite the user's content
            # with `{}`. Back it up once and leave the file untouched.
            bak = path + ".adk-bak"
            if not os.path.exists(bak):
                try:
                    shutil.copy2(path, bak)
                except OSError:
                    pass
            sys.stderr.write(
                "hooks_merge: %s is not a valid JSON object; left unchanged "
                "(backup at %s).\n" % (path, bak))
            sys.exit(0)

    hooks = data.get("hooks")
    if not isinstance(hooks, dict):
        hooks = {}

    for key, additions in (
        ("PreToolUse",
         ([] if remove else
          (GUARD_ENTRIES if want_guards else []) +
          (PROCESS_PRE_ENTRIES if want_process else []))),
        ("Stop",
         ([] if remove else
          (PROCESS_STOP_ENTRIES if want_process else []))),
    ):
        cur = hooks.get(key)
        cur = [e for e in cur if not is_kit_entry(e)] if isinstance(cur, list) else []
        cur.extend(additions)
        if cur:
            hooks[key] = cur
        else:
            hooks.pop(key, None)

    if hooks:
        data["hooks"] = hooks
    else:
        data.pop("hooks", None)

    os.makedirs(os.path.dirname(path) or ".", exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2)
        f.write("\n")


if __name__ == "__main__":
    main()
