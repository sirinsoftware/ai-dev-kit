# lib/scaffold.sh - render templates into the TARGET_DIR project. Idempotent.
# shellcheck shell=bash
[ -n "${_ADK_SCAFFOLD_SOURCED:-}" ] && return 0
_ADK_SCAFFOLD_SOURCED=1

# Ensure CLAUDE.md exists with `@AGENTS.md` as its first line, then a managed notes block.
ensure_claude_md() {
  local f="$1"
  if [ ! -f "$f" ]; then
    printf '@AGENTS.md\n' > "$f"
  elif ! head -n1 "$f" | grep -qxF '@AGENTS.md'; then
    backup_once "$f"
    local tmp; tmp="$(mktemp)"
    printf '@AGENTS.md\n\n' > "$tmp"
    cat "$f" >> "$tmp"
    mv "$tmp" "$f"
  fi
  upsert_block "$f" "claude-notes" "<!--" "-->" < "$ADK_ROOT/templates/claude/CLAUDE.notes.md.tmpl"
}

scaffold_project() {
  log_step "Scaffolding shared files into $TARGET_DIR"
  local KIT="$ADK_ROOT"
  : "${PROJECT_NAME:=$(basename "$TARGET_DIR")}"
  : "${ADK_DATE:=$(date +%Y-%m-%d)}"
  export PROJECT_NAME ADK_DATE

  # 1. AGENTS.md - single source of truth. Never clobber an existing one.
  if [ ! -f "$TARGET_DIR/AGENTS.md" ]; then
    render_template "$KIT/templates/AGENTS.md.tmpl" "$TARGET_DIR/AGENTS.md"
    log_success "AGENTS.md created - fill in the {{...}} placeholders."
  else
    log_info "AGENTS.md already exists - left untouched (it is your source of truth)."
  fi

  # 2. Prompt library -> docs/ai-prompts/
  mkdir -p "$TARGET_DIR/docs/ai-prompts"
  local p
  for p in "$KIT"/templates/prompts/*.md; do
    [ -e "$p" ] || continue
    cp "$p" "$TARGET_DIR/docs/ai-prompts/$(basename "$p")"
  done
  render_template "$KIT/templates/prompts/00-standards.md.tmpl" "$TARGET_DIR/docs/ai-prompts/00-standards.md"
  log_success "Prompt library -> docs/ai-prompts/ (edit 00-standards.md first)."

  # 3. Claude Code
  if [ -n "${EN_CLAUDE:-}" ]; then
    render_template "$KIT/templates/claude/settings.json.tmpl" "$TARGET_DIR/.claude/settings.json"
    ensure_claude_md "$TARGET_DIR/CLAUDE.md"
    log_success "Claude Code -> CLAUDE.md (@AGENTS.md import) + .claude/settings.json (model=$CLAUDE_MODEL)"
  fi

  # 4. Codex
  if [ -n "${EN_CODEX:-}" ]; then
    render_template "$KIT/templates/codex/config.toml.tmpl" "$TARGET_DIR/.codex/config.toml"
    log_success "Codex -> .codex/config.toml (model=$CODEX_MODEL). Reads AGENTS.md natively."
  fi

  # 5. Copilot
  if [ -n "${EN_COPILOT:-}" ]; then
    render_template "$KIT/templates/copilot/copilot-instructions.md.tmpl" "$TARGET_DIR/.github/copilot-instructions.md"
    render_template "$KIT/templates/copilot/copilot-setup-steps.yml.tmpl" "$TARGET_DIR/.github/workflows/copilot-setup-steps.yml"
    log_success "Copilot -> .github/copilot-instructions.md + workflows/copilot-setup-steps.yml"
  fi

  # 6. .gitignore hygiene
  ensure_line_in_file "$TARGET_DIR/.gitignore" "graphify-out/"
  ensure_line_in_file "$TARGET_DIR/.gitignore" "*.local.*"
  ensure_line_in_file "$TARGET_DIR/.gitignore" ".claude/settings.local.json"
  ensure_line_in_file "$TARGET_DIR/.gitignore" "*.adk-bak"
}
