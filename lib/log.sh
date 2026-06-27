# lib/log.sh - logging + small run helpers. Sourced by setup.sh; defines functions only.
# shellcheck shell=bash
[ -n "${_ADK_LOG_SOURCED:-}" ] && return 0
_ADK_LOG_SOURCED=1

if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
  _c_reset=$'\033[0m'; _c_red=$'\033[31m'; _c_grn=$'\033[32m'
  _c_yel=$'\033[33m'; _c_blu=$'\033[34m'; _c_dim=$'\033[2m'; _c_bold=$'\033[1m'
else
  _c_reset=''; _c_red=''; _c_grn=''; _c_yel=''; _c_blu=''; _c_dim=''; _c_bold=''
fi

log_info()    { [ -n "${QUIET:-}" ] && return 0; printf '%s\n' "${_c_blu}-${_c_reset} $*"; }
log_step()    { [ -n "${QUIET:-}" ] && return 0; printf '\n%s\n' "${_c_bold}${_c_blu}==>${_c_reset} ${_c_bold}$*${_c_reset}"; }
log_success() { [ -n "${QUIET:-}" ] && return 0; printf '%s\n' "${_c_grn}+${_c_reset} $*"; }
log_dim()     { [ -n "${QUIET:-}" ] && return 0; printf '%s\n' "${_c_dim}  $*${_c_reset}"; }
log_warn()    { printf '%s\n' "${_c_yel}!${_c_reset} $*" >&2; }
log_error()   { printf '%s\n' "${_c_red}x${_c_reset} $*" >&2; }
die()         { log_error "$*"; exit 1; }

is_dry() { [ -n "${DRY_RUN:-}" ]; }
