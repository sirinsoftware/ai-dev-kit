#!/usr/bin/env python3
"""ai-dev-kit PreToolUse guard for Bash. Blocks clearly-dangerous commands.

Claude Code feeds the tool call as JSON on stdin; exit code 2 blocks the call
and shows the stderr message to the model. Conservative by design: a recursive
force-delete is blocked only when it targets an absolute path, $HOME/~, the
cwd/parent (`.` `..` `./` `../`), or a root/cwd-wide glob (`*` `./*`) — so
everyday `rm -rf build/` style deletes still work. `rm` is matched by basename,
so `/bin/rm`, `\\rm`, and `command rm` are caught too. Obfuscation through
command substitution / eval (`$(echo rm) ...`) is out of scope for a textual
guard. Edit DANGER / the dangerous-target set below to tune.
"""
import json
import os
import re
import sys

# Misc catastrophes (regex). rm -rf is handled separately by _dangerous_rm().
DANGER = [
    r"--no-preserve-root",
    r":\(\)\s*\{\s*:\s*\|\s*:\s*&\s*\}\s*;",            # fork bomb
    r"\bmkfs\.",
    r"\bdd\b[^\n]*\bof=/dev/",
    r">\s*/dev/sd[a-z]",
    r"\bchmod\s+-[A-Za-z]*\s*777\b|\bchmod\s+777\b",
    r"\bsudo\s+rm\b",
    r"(curl|wget)\b[^|]*\|\s*(sudo\s+)?(ba|z|fi)?sh\b",  # curl ... | sh
    r"git\s+push\b[^\n]*(--force|--force-with-lease|\s-f\b)[^\n]*\b(origin/)?(main|master)\b",
    r"git\s+push\b[^\n]*\b(origin/)?(main|master)\b[^\n]*(--force|\s-f\b)",
]


def _is_dangerous_target(arg):
    a = arg.strip().strip('"').strip("'").strip()
    if not a:
        return False
    base = a.rstrip("/")
    if base in ("", ".", ".."):                 # / // . ./ .. ../  (root, cwd, parent)
        return True
    if a.startswith("/"):                        # any absolute path: /etc, /important
        return True
    if a.startswith(("~", "$HOME", "${HOME}")):  # home dir (~ , ~/ , ~/foo, $HOME/...)
        return True
    if a.startswith("../") or a.startswith("..\\"):   # climbs above the cwd
        return True
    if re.fullmatch(r"\.?/?\*+", a):             # *  ./*  (root/cwd-wide glob)
        return True
    return False


def _is_rm_token(tok):
    """True if a token invokes rm regardless of path/quoting: rm, /bin/rm, \\rm, 'rm'."""
    t = tok.strip().strip('"').strip("'").lstrip("\\")
    return os.path.basename(t) == "rm"


def _dangerous_rm(cmd):
    """True if any segment is `rm` with recursive+force flags on a dangerous target."""
    for seg in re.split(r"&&|\|\||;|\n|\|", cmd):
        toks = seg.split()
        idx = next((k for k, t in enumerate(toks) if _is_rm_token(t)), None)
        if idx is None:
            continue
        rest = toks[idx + 1:]
        recursive = force = end_opts = False
        targets = []
        for t in rest:
            if not end_opts and t == "--":      # POSIX end-of-options
                end_opts = True
            elif not end_opts and t.startswith("--"):
                if t == "--recursive":
                    recursive = True
                elif t == "--force":
                    force = True
            elif not end_opts and t.startswith("-") and len(t) > 1:
                if "r" in t[1:].lower():
                    recursive = True
                if "f" in t[1:]:
                    force = True
            else:
                targets.append(t)
        if recursive and force and any(_is_dangerous_target(t) for t in targets):
            return True
    return False


def main():
    try:
        data = json.load(sys.stdin)
    except (ValueError, OSError):
        sys.exit(0)
    cmd = (data.get("tool_input") or {}).get("command", "") or ""
    blocked = _dangerous_rm(cmd) or any(re.search(p, cmd) for p in DANGER)
    if blocked:
        sys.stderr.write(
            "[ai-dev-kit guard] Blocked a dangerous shell command (matched a safety "
            "rule). If this is a false positive, edit .claude/hooks/guard-bash.py.\n"
            "Command: " + cmd[:300] + "\n"
        )
        sys.exit(2)
    sys.exit(0)


if __name__ == "__main__":
    main()
