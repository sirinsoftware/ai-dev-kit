# lib/detect.sh - OS / arch / package-manager / tooling detection.
# shellcheck shell=bash
[ -n "${_ADK_DETECT_SOURCED:-}" ] && return 0
_ADK_DETECT_SOURCED=1

# has_cmd <name> -> 0 if the command exists on PATH
has_cmd() { command -v "$1" >/dev/null 2>&1; }

detect_os() {
  case "$(uname -s)" in
    Darwin) ADK_OS=darwin ;;
    Linux)  ADK_OS=linux ;;
    *)      ADK_OS=unknown ;;
  esac
  export ADK_OS
}

detect_arch() {
  case "$(uname -m)" in
    arm64|aarch64) ADK_ARCH=arm64 ;;
    x86_64|amd64)  ADK_ARCH=x86_64 ;;
    *)             ADK_ARCH="$(uname -m)" ;;
  esac
  export ADK_ARCH
}

# Pick a package manager we know how to drive.
detect_pkg_mgr() {
  if has_cmd brew;    then ADK_PKG=brew
  elif has_cmd apt-get; then ADK_PKG=apt
  elif has_cmd dnf;   then ADK_PKG=dnf
  else                     ADK_PKG=none
  fi
  export ADK_PKG
}
