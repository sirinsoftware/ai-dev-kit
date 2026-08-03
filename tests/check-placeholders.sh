#!/usr/bin/env bash
#
# Drift guard: every {{PLACEHOLDER}} in templates/AGENTS.md.tmpl must be referenced in
# templates/commands/fill-agents.md, so /fill-agents can't silently miss a field when
# someone adds a placeholder to the template.
#
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmpl="$root/templates/AGENTS.md.tmpl"
cmd="$root/templates/commands/fill-agents.md"

# Real fields only; {{PLACEHOLDER}} is the template's own how-to example, not a field.
placeholders="$(grep -oE '\{\{[A-Z_]+\}\}' "$tmpl" | sort -u | grep -vx '{{PLACEHOLDER}}')"
[ -n "$placeholders" ] || { echo "FAIL: no {{...}} placeholders found in $tmpl"; exit 1; }

missing=0
while IFS= read -r p; do
  grep -qF "$p" "$cmd" || { echo "MISSING: $p is in AGENTS.md.tmpl but not in fill-agents.md"; missing=1; }
done <<< "$placeholders"

[ "$missing" -eq 0 ] || { echo "FAIL: fill-agents.md is out of sync with AGENTS.md.tmpl"; exit 1; }
echo "OK: fill-agents.md covers all $(printf '%s\n' "$placeholders" | wc -l | tr -d ' ') placeholders"
