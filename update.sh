#!/usr/bin/env bash
#
# ai-dev-kit update - upgrade the third-party tools ai-dev-kit installs, then
# rebuild the code graph. Run from anywhere:
#
#   ~/.ai-dev-kit/update.sh [TARGET_DIR]
#
# Only upgrades what's actually installed (detected on PATH). Agent plugins
# (Superpowers, ponytail) can't be driven from a shell - it prints the commands
# to run inside your agent instead. The MCP servers (Grep, private-journal) run
# via `npx -y`, so they self-update on launch. This does NOT touch the kit's own
# scaffolded files or re-run setup - use setup.sh for that.
#
set -euo pipefail

ADK_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export ADK_ROOT

TARGET_DIR="$(pwd)"
DRY_RUN=""; ASSUME_YES=""

usage() {
  cat <<'EOF'
ai-dev-kit update - upgrade installed tools + rebuild the code graph

Usage: ~/.ai-dev-kit/update.sh [TARGET_DIR] [options]

  TARGET_DIR        Project whose code graph to rebuild (default: current dir)

Options:
  --dry-run         Print what would be upgraded; change nothing
  -y, --yes         Non-interactive
  -h, --help        Show this help
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run)  DRY_RUN=1 ;;
    -y|--yes)   ASSUME_YES=1 ;;
    -h|--help)  usage; exit 0 ;;
    -*)         echo "Unknown option: $1" >&2; usage; exit 2 ;;
    *)          TARGET_DIR="$1" ;;
  esac
  shift
done
export DRY_RUN ASSUME_YES

# shellcheck source=/dev/null
for f in log detect prompt; do . "$ADK_ROOT/lib/$f.sh"; done
detect_os; detect_arch; detect_pkg_mgr

# uv tool binaries live in ~/.local/bin by default; make sure this run can see them.
case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *) PATH="$HOME/.local/bin:$PATH"; export PATH ;; esac

# run <description> <cmd...> : log + execute, or just print under --dry-run.
run() {
  local desc="$1"; shift
  log_info "$desc"
  if is_dry; then log_dim "[dry] $*"; return 0; fi
  "$@"
}

[ -d "$TARGET_DIR" ] || die "Target directory not found: $TARGET_DIR"
TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"

log_step "ai-dev-kit update -> $TARGET_DIR   (${ADK_OS}/${ADK_ARCH}, pkg=${ADK_PKG})"
is_dry && log_warn "DRY RUN - nothing will be upgraded or rebuilt."

# 1. uv tools: graphify (PyPI graphifyy) + spec-kit (specify-cli).
if has_cmd uv; then
  if has_cmd graphify; then
    run "graphify -> latest" uv tool upgrade graphifyy || log_warn "graphify upgrade failed."
  fi
  if has_cmd specify; then
    run "spec-kit -> latest" uv tool upgrade specify-cli || log_warn "spec-kit upgrade failed."
  fi
elif has_cmd graphify || has_cmd specify; then
  log_warn "graphify/spec-kit are installed but 'uv' is not on PATH - can't upgrade them."
  log_dim "Install uv (https://astral.sh/uv), then re-run this."
fi

# 2. Rebuild the code graph (headless, no API key) when one already exists.
if has_cmd graphify && [ -f "$TARGET_DIR/graphify-out/graph.json" ]; then
  log_info "rebuild code graph (graphify update .)"
  if is_dry; then
    log_dim "[dry] (cd \"$TARGET_DIR\" && graphify update .)"
  else
    ( cd "$TARGET_DIR" && graphify update . ) || log_warn "graph rebuild failed - run 'graphify update .' manually."
  fi
elif has_cmd graphify; then
  log_dim "No graphify-out/graph.json in $TARGET_DIR - skipping graph rebuild."
fi

# 3. Agent plugins - a shell can't drive /plugin; upgrade them inside each agent.
log_step "Agent plugins - upgrade inside each agent (a shell can't do this)"
log_info "In Claude Code: run /plugin, choose Manage, and update: superpowers, ponytail"
log_dim "Or re-install to force latest:"
log_dim "  /plugin marketplace add obra/superpowers-marketplace  &&  /plugin install superpowers"
log_dim "  /plugin marketplace add DietrichGebert/ponytail       &&  /plugin install ponytail@ponytail"

# 4. MCP servers self-update via npx.
log_dim "Grep + private-journal MCP run via 'npx -y' and pull latest on each launch - nothing to do."

log_step "Update complete"
