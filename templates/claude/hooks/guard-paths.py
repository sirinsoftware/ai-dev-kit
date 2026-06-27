#!/usr/bin/env python3
"""ai-dev-kit PreToolUse guard for Read/Edit/Write. Blocks likely secret files.

Exit 2 blocks the tool call and shows the message to the model. `.env.example`
and similar templates are explicitly allowed. Edit the lists below to tune.
"""
import json
import re
import sys

ALLOW = [
    r"\.env\.(example|sample|template|dist)$",
    r"\.env\.example",
]
DENY = [
    r"(^|/)\.env($|\.[^/]*$)",
    r"\.pem$",
    r"\.p12$",
    r"\.pfx$",
    r"(^|/)id_(rsa|dsa|ecdsa|ed25519)(\.pub)?$",
    r"(^|/)\.ssh/",
    r"(^|/)\.aws/credentials",
    r"(^|/)\.npmrc$",
    r"(^|/)\.netrc$",
    r"(^|/)secrets?\.(ya?ml|json|toml|env)$",
    r"(^|/)credentials?\.(ya?ml|json|toml)$",
]


def main():
    try:
        data = json.load(sys.stdin)
    except (ValueError, OSError):
        sys.exit(0)
    ti = data.get("tool_input") or {}
    path = ti.get("file_path") or ti.get("path") or ""
    if not path:
        sys.exit(0)
    if any(re.search(p, path) for p in ALLOW):
        sys.exit(0)
    if any(re.search(p, path) for p in DENY):
        sys.stderr.write(
            "[ai-dev-kit guard] Blocked access to a likely secret file: "
            + path
            + "\nIf this is intentional, edit .claude/hooks/guard-paths.py.\n"
        )
        sys.exit(2)
    sys.exit(0)


if __name__ == "__main__":
    main()
