# lib/configure_codex.sh — verify the OpenAI Codex CLI, note Superpowers steps.
# Assumes the user already has the Codex CLI installed.
# shellcheck shell=bash
[ -n "${_ADK_CONFIGURE_CODEX_SOURCED:-}" ] && return 0
_ADK_CONFIGURE_CODEX_SOURCED=1

configure_codex() {
  log_step "OpenAI Codex (GPT models)"

  if has_cmd codex; then
    local ver; ver="$(codex --version 2>/dev/null | head -n1 || true)"
    log_success "Codex CLI detected (${ver})."
  else
    log_warn "Codex CLI not found on PATH."
    log_dim  "Install it first (e.g. 'npm i -g @openai/codex' or 'brew install --cask codex'), then re-run."
  fi

  log_dim "Codex reads ./AGENTS.md natively; .codex/config.toml loads once you 'trust' the project."

  if [ -n "${WANT_SUPERPOWERS:-}" ]; then
    log_info "Superpowers for Codex is interactive:"
    log_dim  "run 'codex', then '/plugins', then select 'superpowers'."
  fi
}
