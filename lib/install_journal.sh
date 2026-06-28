# lib/install_journal.sh - build private-journal-mcp once.
# It's GitHub-only (not on npm) and TypeScript with a tsc build, so launching it via
# `npx github:obra/private-journal-mcp` rebuilds on EVERY start — too slow for an MCP
# connect window (it "never surfaces"). We clone+build once into a stable dir and the
# MCP launches the built file directly (instant).
# shellcheck shell=bash
[ -n "${_ADK_INSTALL_JOURNAL_SOURCED:-}" ] && return 0
_ADK_INSTALL_JOURNAL_SOURCED=1

ADK_JOURNAL_DIR="${ADK_JOURNAL_DIR:-$HOME/.ai-dev-kit-tools/private-journal-mcp}"
export ADK_JOURNAL_DIR
adk_journal_entry() { printf '%s' "$ADK_JOURNAL_DIR/dist/index.js"; }

install_journal() {
  log_step "private-journal (cross-session memory MCP)"
  if [ -f "$(adk_journal_entry)" ]; then
    log_success "private-journal already built ($ADK_JOURNAL_DIR)."
    return 0
  fi
  if ! has_cmd git || ! has_cmd npm; then
    log_warn "private-journal needs git + npm to build — skipping."
    return 1
  fi
  log_info "Building private-journal-mcp once (clone + tsc) into $ADK_JOURNAL_DIR…"
  mkdir -p "$(dirname "$ADK_JOURNAL_DIR")"
  rm -rf "$ADK_JOURNAL_DIR"
  if git clone --depth 1 https://github.com/obra/private-journal-mcp "$ADK_JOURNAL_DIR" >/dev/null 2>&1 \
     && ( cd "$ADK_JOURNAL_DIR" && npm install >/dev/null 2>&1 && npm run build >/dev/null 2>&1 ) \
     && [ -f "$(adk_journal_entry)" ]; then
    log_success "private-journal built."
    return 0
  fi
  log_warn "private-journal build failed — it won't be registered."
  return 1
}
