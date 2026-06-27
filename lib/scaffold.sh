# lib/scaffold.sh - render templates into the TARGET_DIR project. Idempotent.
# shellcheck shell=bash
[ -n "${_ADK_SCAFFOLD_SOURCED:-}" ] && return 0
_ADK_SCAFFOLD_SOURCED=1

# The reusable commands shipped as native slash commands per tool.
ADK_COMMANDS="pr-review progress-report deep-test repeatable-task"

_cmd_desc() {
  case "$1" in
    pr-review)       echo "Review a PR: correctness, security, standards; re-review, report, fix, describe." ;;
    progress-report) echo "Generate a project progress report for a given period." ;;
    deep-test)       echo "Design and run an in-depth testing algorithm for a target." ;;
    repeatable-task) echo "Turn a recurring task into a deterministic, repeatable runbook." ;;
    *)               echo "ai-dev-kit command." ;;
  esac
}

_cmd_hint() {
  case "$1" in
    pr-review)       echo "PR ref or URL (default: current diff)" ;;
    progress-report) echo "period, e.g. 'this week'" ;;
    deep-test)       echo "file / module / feature to test" ;;
    repeatable-task) echo "task to codify" ;;
    *)               echo "argument" ;;
  esac
}

# Claude Code: .claude/commands/<name>.md  (argument via $ARGUMENTS)
_write_command_claude() {
  local name="$1" body="$2" dest="$TARGET_DIR/.claude/commands/$1.md" tmp
  mkdir -p "$TARGET_DIR/.claude/commands"; tmp="$(mktemp)"
  {
    printf -- '---\n'
    printf 'description: %s\n' "$(_cmd_desc "$name")"
    printf 'argument-hint: "%s"\n' "$(_cmd_hint "$name")"
    printf -- '---\n\n'
    sed 's/__ARG__/$ARGUMENTS/g' "$body"
  } > "$tmp"
  [ -f "$dest" ] && backup_once "$dest"
  mv "$tmp" "$dest"
}

# Codex CLI: $CODEX_HOME/prompts/<name>.md (USER-GLOBAL; argument via $ARGUMENTS). Invoke /prompts:<name>
_write_command_codex() {
  local name="$1" body="$2" dir dest tmp
  dir="${CODEX_HOME:-$HOME/.codex}/prompts"; dest="$dir/$1.md"
  mkdir -p "$dir"; tmp="$(mktemp)"
  {
    printf -- '---\n'
    printf 'description: %s\n' "$(_cmd_desc "$name")"
    printf 'argument-hint: "%s"\n' "$(_cmd_hint "$name")"
    printf -- '---\n\n'
    sed 's/__ARG__/$ARGUMENTS/g' "$body"
  } > "$tmp"
  [ -f "$dest" ] && backup_once "$dest"
  mv "$tmp" "$dest"
}

# Copilot: .github/prompts/<name>.prompt.md (IDE chat only; argument via ${input:arg})
_write_command_copilot() {
  local name="$1" body="$2" dest="$TARGET_DIR/.github/prompts/$1.prompt.md" tmp
  mkdir -p "$TARGET_DIR/.github/prompts"; tmp="$(mktemp)"
  {
    printf -- '---\n'
    printf 'description: %s\n' "$(_cmd_desc "$name")"
    printf 'mode: agent\n'
    printf -- '---\n\n'
    sed 's/__ARG__/${input:arg}/g' "$body"
  } > "$tmp"
  [ -f "$dest" ] && backup_once "$dest"
  mv "$tmp" "$dest"
}

scaffold_commands() {
  local KIT="$ADK_ROOT" name body
  for name in $ADK_COMMANDS; do
    body="$KIT/templates/commands/$name.md"
    [ -f "$body" ] || continue
    [ -n "${EN_CLAUDE:-}" ]  && _write_command_claude  "$name" "$body"
    [ -n "${EN_CODEX:-}" ]   && _write_command_codex   "$name" "$body"
    [ -n "${EN_COPILOT:-}" ] && _write_command_copilot "$name" "$body"
  done
  [ -n "${EN_CLAUDE:-}" ]  && log_success "Claude commands -> .claude/commands/*.md (invoke: /pr-review …)"
  [ -n "${EN_COPILOT:-}" ] && log_success "Copilot prompts -> .github/prompts/*.prompt.md (IDE chat: /pr-review …)"
  if [ -n "${EN_CODEX:-}" ]; then
    log_success "Codex prompts -> ${CODEX_HOME:-$HOME/.codex}/prompts/*.md (USER-GLOBAL; invoke: /prompts:pr-review …)"
    log_dim "Codex prompts are global (no per-project scope) and need a Codex restart to appear."
  fi
}

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

  # 1. AGENTS.md - single source of truth (incl. Standards). Never clobber an existing one.
  if [ ! -f "$TARGET_DIR/AGENTS.md" ]; then
    render_template "$KIT/templates/AGENTS.md.tmpl" "$TARGET_DIR/AGENTS.md"
    log_success "AGENTS.md created - fill in the {{...}} placeholders (incl. the Standards section)."
  else
    log_info "AGENTS.md already exists - left untouched (it is your source of truth)."
  fi

  # 2. Claude Code
  if [ -n "${EN_CLAUDE:-}" ]; then
    render_template "$KIT/templates/claude/settings.json.tmpl" "$TARGET_DIR/.claude/settings.json"
    ensure_claude_md "$TARGET_DIR/CLAUDE.md"
    log_success "Claude Code -> CLAUDE.md (@AGENTS.md import) + .claude/settings.json (model=$CLAUDE_MODEL)"
  fi

  # 3. Codex
  if [ -n "${EN_CODEX:-}" ]; then
    render_template "$KIT/templates/codex/config.toml.tmpl" "$TARGET_DIR/.codex/config.toml"
    log_success "Codex -> .codex/config.toml (model=$CODEX_MODEL). Reads AGENTS.md natively."
  fi

  # 4. Copilot
  if [ -n "${EN_COPILOT:-}" ]; then
    render_template "$KIT/templates/copilot/copilot-instructions.md.tmpl" "$TARGET_DIR/.github/copilot-instructions.md"
    render_template "$KIT/templates/copilot/copilot-setup-steps.yml.tmpl" "$TARGET_DIR/.github/workflows/copilot-setup-steps.yml"
    log_success "Copilot -> .github/copilot-instructions.md + workflows/copilot-setup-steps.yml"
  fi

  # 5. Reusable commands (native slash commands per enabled tool)
  scaffold_commands

  # 6. .gitignore hygiene
  ensure_line_in_file "$TARGET_DIR/.gitignore" "graphify-out/"
  ensure_line_in_file "$TARGET_DIR/.gitignore" "*.local.*"
  ensure_line_in_file "$TARGET_DIR/.gitignore" ".claude/settings.local.json"
  ensure_line_in_file "$TARGET_DIR/.gitignore" "*.adk-bak"
}
