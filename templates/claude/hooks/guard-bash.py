#!/usr/bin/env python3
"""ai-dev-kit PreToolUse guard for Bash. Blocks clearly-dangerous commands.

Claude Code feeds the tool call as JSON on stdin; exit code 2 blocks the call
and shows the stderr message to the model. Conservative by design — only
unambiguous catastrophes are blocked. Edit DANGER below to tune.
"""
import json
import re
import sys

DANGER = [
    r"\brm\s+-[a-z]*r[a-z]*f[a-z]*\s+(/|~|\$HOME|/\*|\*)\s*($|\s)",
    r"\brm\s+-[a-z]*f[a-z]*r[a-z]*\s+(/|~|\$HOME|/\*|\*)\s*($|\s)",
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


def main():
    try:
        data = json.load(sys.stdin)
    except (ValueError, OSError):
        sys.exit(0)
    cmd = (data.get("tool_input") or {}).get("command", "") or ""
    for pat in DANGER:
        if re.search(pat, cmd):
            sys.stderr.write(
                "[ai-dev-kit guard] Blocked a dangerous shell command "
                "(matched a safety rule). If this is a false positive, edit "
                ".claude/hooks/guard-bash.py.\nCommand: " + cmd[:300] + "\n"
            )
            sys.exit(2)
    sys.exit(0)


if __name__ == "__main__":
    main()
