# lib/prompt.sh - interactive prompts that survive `curl ... | bash` (read from /dev/tty).
# Honors ASSUME_YES (non-interactive: take the default). Prompts go to stderr so
# command-substitution callers ($(ask ...)) capture only the answer.
# shellcheck shell=bash
[ -n "${_ADK_PROMPT_SOURCED:-}" ] && return 0
_ADK_PROMPT_SOURCED=1

# _read_tty <varname> : read one line from the controlling terminal.
# Falls back to stdin only when stdin IS a terminal. Returns 1 when there is no
# usable terminal, so callers can take their default instead of consuming stdin.
_read_tty() {
  local __var="$1"
  if { exec 3<>/dev/tty; } 2>/dev/null; then
    IFS= read -r "$__var" <&3 || true
    exec 3<&-
  elif [ -t 0 ]; then
    IFS= read -r "$__var" || true
  else
    return 1
  fi
}

# confirm "Question?" [default y|n] -> exit 0 = yes, 1 = no
confirm() {
  local q="$1" def="${2:-y}" ans hint
  # Uniform casing everywhere ([y/n]); the default is stated explicitly rather than
  # implied by which letter is capitalized (which read as inconsistent).
  case "$def" in y|Y) hint="[y/n] (default: yes)" ;; *) hint="[y/n] (default: no)" ;; esac
  if [ -n "${ASSUME_YES:-}" ]; then
    case "$def" in y|Y) return 0 ;; *) return 1 ;; esac
  fi
  printf '%s ' "${_c_blu}?${_c_reset} $q $hint" >&2
  if ! _read_tty ans; then
    log_warn "No terminal available - using default ($def) for: $q"
    ans="$def"
  fi
  ans="${ans:-$def}"
  case "$ans" in y|Y|yes|YES|Yes) return 0 ;; *) return 1 ;; esac
}

# ask "Prompt" "default" -> echoes the answer (or the default) on stdout
ask() {
  local q="$1" def="$2" ans
  if [ -n "${ASSUME_YES:-}" ]; then printf '%s' "$def"; return 0; fi
  printf '%s ' "${_c_blu}?${_c_reset} $q [${def}]:" >&2
  _read_tty ans || ans="$def"
  printf '%s' "${ans:-$def}"
}
