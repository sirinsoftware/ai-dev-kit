# lib/idempotent.sh - safe, re-runnable file operations.
# shellcheck shell=bash
[ -n "${_ADK_IDEMP_SOURCED:-}" ] && return 0
_ADK_IDEMP_SOURCED=1

# backup_once <file> : copy <file> to <file>.adk-bak the first time we touch it.
backup_once() {
  local f="$1"
  [ -f "$f" ] || return 0
  [ -f "$f.adk-bak" ] && return 0
  cp "$f" "$f.adk-bak"
}

# ensure_line_in_file <file> <line> : append <line> unless an exact match exists.
ensure_line_in_file() {
  local file="$1" line="$2"
  mkdir -p "$(dirname "$file")"
  touch "$file"
  grep -qxF -- "$line" "$file" 2>/dev/null && return 0
  printf '%s\n' "$line" >> "$file"
}

# render_template <src> <dest>
#   Copies <src> to <dest>, substituting @@VAR@@ tokens from a fixed allow-list of
#   environment variables. User-facing {{PLACEHOLDERS}} are deliberately left intact.
#   Existing <dest> is overwritten (callers gate writes + handle conflict backups).
render_template() {
  local src="$1" dest="$2" tmp v val esc
  [ -f "$src" ] || { log_warn "template missing: $src"; return 1; }
  tmp="$(mktemp)"
  trap 'rm -f "$tmp" "$tmp.new"' RETURN
  cp "$src" "$tmp"
  for v in PROJECT_NAME CLAUDE_MODEL CODEX_MODEL CODEX_REASONING ADK_DATE; do
    val="${!v:-}"
    # Escape chars that are special on the replacement side of sed s|...|...|
    esc="$(printf '%s' "$val" | sed -e 's/[\\&|]/\\&/g')"
    sed "s|@@${v}@@|${esc}|g" "$tmp" > "$tmp.new" && mv "$tmp.new" "$tmp"
  done
  mkdir -p "$(dirname "$dest")"
  mv "$tmp" "$dest"
  trap - RETURN
}

# upsert_block <file> <id> [open_comment] [close_comment]   (block body read from stdin)
#   Inserts or replaces a marker-delimited block so re-runs only touch our content
#   and leave the user's surrounding edits alone.
#   Defaults to shell-style markers (open="#", no close). For Markdown pass "<!--" "-->".
upsert_block() {
  local file="$1" id="$2" open="${3:-#}" close="${4:-}"
  local cfile tmp begin end
  cfile="$(mktemp)"; cat > "$cfile"
  trap 'rm -f "$cfile" "${tmp:-}"' RETURN
  if [ -n "$close" ]; then
    begin="$open >>> ai-dev-kit:$id >>> $close"
    end="$open <<< ai-dev-kit:$id <<< $close"
  else
    begin="$open >>> ai-dev-kit:$id >>>"
    end="$open <<< ai-dev-kit:$id <<<"
  fi
  mkdir -p "$(dirname "$file")"; touch "$file"
  tmp="$(mktemp)"
  if grep -qF -- "$begin" "$file"; then
    awk -v b="$begin" -v e="$end" -v cf="$cfile" '
      { if ($0==b) { print; while ((getline l < cf) > 0) print l; close(cf); inb=1; next }
        if ($0==e) { inb=0; print; next }
        if (!inb) print }
    ' "$file" > "$tmp"
  else
    cat "$file" > "$tmp"
    [ -s "$tmp" ] && [ -n "$(tail -c1 "$tmp")" ] && printf '\n' >> "$tmp"
    printf '%s\n' "$begin" >> "$tmp"
    cat "$cfile" >> "$tmp"
    printf '%s\n' "$end" >> "$tmp"
  fi
  mv "$tmp" "$file"
  rm -f "$cfile"
  trap - RETURN
}

# remove_block <file> <id> [open_comment] [close_comment]
#   Delete a marker-delimited block (and its markers) written by upsert_block.
#   No-op if the file or block is absent.
remove_block() {
  local file="$1" id="$2" open="${3:-#}" close="${4:-}" begin end tmp
  [ -f "$file" ] || return 0
  if [ -n "$close" ]; then
    begin="$open >>> ai-dev-kit:$id >>> $close"
    end="$open <<< ai-dev-kit:$id <<< $close"
  else
    begin="$open >>> ai-dev-kit:$id >>>"
    end="$open <<< ai-dev-kit:$id <<<"
  fi
  grep -qF -- "$begin" "$file" || return 0
  tmp="$(mktemp)"
  awk -v b="$begin" -v e="$end" '
    $0==b {inb=1; next}
    $0==e {inb=0; next}
    !inb {print}
  ' "$file" > "$tmp"
  mv "$tmp" "$file"
}
