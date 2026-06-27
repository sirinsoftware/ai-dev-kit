#!/usr/bin/env python3
"""Upsert or remove an MCP server entry in a JSON config, preserving other keys.

Used for Claude Code (.mcp.json, root key "mcpServers") and GitHub Copilot /
VS Code (.vscode/mcp.json, root key "servers"). Codex TOML is handled in bash.

Usage:
  mcp_upsert.py <file> <root_key> add <name> <http|stdio> <target> [args...]
  mcp_upsert.py <file> <root_key> remove <name>
"""
import json
import os
import sys


def load(path):
    if os.path.exists(path) and os.path.getsize(path) > 0:
        try:
            with open(path, encoding="utf-8") as f:
                d = json.load(f)
            return d if isinstance(d, dict) else {}
        except (ValueError, OSError):
            return {}
    return {}


def main():
    if len(sys.argv) < 5:
        sys.exit("mcp_upsert: too few arguments")
    path, root, op, name = sys.argv[1:5]
    data = load(path)
    servers = data.get(root)
    if not isinstance(servers, dict):
        servers = {}

    if op == "add":
        transport = sys.argv[5]
        target = sys.argv[6]
        rest = sys.argv[7:]
        if transport == "http":
            servers[name] = {"type": "http", "url": target}
        else:
            servers[name] = {"type": "stdio", "command": target, "args": rest}
    elif op == "remove":
        servers.pop(name, None)
    else:
        sys.exit(f"mcp_upsert: unknown op {op!r}")

    data[root] = servers
    parent = os.path.dirname(path)
    if parent:
        os.makedirs(parent, exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2)
        f.write("\n")


if __name__ == "__main__":
    main()
