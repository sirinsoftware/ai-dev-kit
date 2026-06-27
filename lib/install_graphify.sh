# lib/install_graphify.sh — install graphify (PyPI 'graphifyy', binary 'graphify') + build the graph.
# shellcheck shell=bash
[ -n "${_ADK_INSTALL_GRAPHIFY_SOURCED:-}" ] && return 0
_ADK_INSTALL_GRAPHIFY_SOURCED=1

install_graphify() {
  log_step "graphify (code knowledge graph)"

  if ! has_cmd uv; then
    if confirm "graphify needs 'uv' (Python tool runner). Install uv now?" y; then
      if [ "$ADK_PKG" = brew ]; then
        brew install uv || log_warn "brew install uv failed."
      else
        curl -LsSf https://astral.sh/uv/install.sh | sh || log_warn "uv install script failed."
        # uv installs to ~/.local/bin — make it visible for the rest of this run.
        [ -d "$HOME/.local/bin" ] && PATH="$HOME/.local/bin:$PATH"
      fi
    else
      log_warn "Skipping graphify (uv not installed)."
      return 0
    fi
  fi

  if ! has_cmd uv; then
    log_warn "uv still not on PATH; skipping graphify. Install uv and run 'uv tool install graphifyy' later."
    return 0
  fi

  log_info "Installing graphify (PyPI package 'graphifyy', CLI binary 'graphify')…"
  uv tool install --upgrade graphifyy || { log_warn "graphify install failed."; return 0; }

  # Register the skill with installed assistants (best-effort).
  graphify install >/dev/null 2>&1 || log_dim "graphify skill registration skipped/failed — fine for pure-CLI use."

  if confirm "Build the knowledge graph now for this project?" y; then
    log_info "Building graph (headless: 'graphify extract . --backend ${GRAPHIFY_BACKEND:-claude}')…"
    ( cd "$TARGET_DIR" && graphify extract . --backend "${GRAPHIFY_BACKEND:-claude}" ) \
      && log_success "graphify-out/ created." \
      || log_warn "Headless build failed. For the richer build, open your agent and run '/graphify .'."
  else
    log_dim "Later: 'graphify extract . --backend claude' or run '/graphify .' inside your agent."
  fi
  log_dim "Keep it current after code changes with: graphify update ."
}
