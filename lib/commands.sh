# lib/commands.sh - the reusable slash commands ai-dev-kit ships (single source of
# truth, shared by scaffold.sh and uninstall.sh so they never drift).
# shellcheck shell=bash
[ -n "${_ADK_COMMANDS_SOURCED:-}" ] && return 0
_ADK_COMMANDS_SOURCED=1

ADK_COMMANDS="pr-review progress-report deep-test repeatable-task security-audit report-html"
