# lib/configure_copilot.sh - GitHub Copilot is server-side; note setup + optional CLI Superpowers.
# shellcheck shell=bash
[ -n "${_ADK_CONFIGURE_COPILOT_SOURCED:-}" ] && return 0
_ADK_CONFIGURE_COPILOT_SOURCED=1

configure_copilot() {
  log_step "GitHub Copilot (cloud agent, any model)"

  log_dim "The Copilot cloud agent runs on github.com - nothing to install locally."
  log_dim "It reads ./AGENTS.md and .github/copilot-instructions.md (scaffolded below)."
  log_dim "Model is chosen per-task in the model picker (Pro/Business/Enterprise; admin-gated)."

  if [ -n "${WANT_SUPERPOWERS:-}" ]; then
    if has_cmd copilot; then
      log_info "Installing Superpowers for the Copilot CLI..."
      copilot plugin marketplace add "$SUPERPOWERS_MARKETPLACE" >/dev/null 2>&1 || true
      copilot plugin install superpowers@superpowers-marketplace >/dev/null 2>&1 \
        && log_success "Superpowers installed for Copilot CLI." \
        || log_warn "Could not auto-install Superpowers for the Copilot CLI."
    else
      log_dim "Copilot CLI not found - the cloud agent can't install plugins, so the Superpowers"
      log_dim "methodology is carried via the 'Development workflow' section baked into AGENTS.md."
    fi
  fi
}
