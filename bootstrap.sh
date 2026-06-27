#!/usr/bin/env bash
#
# ai-dev-kit remote bootstrap.
# Clones (or updates) ai-dev-kit, then runs setup.sh against the current directory.
#
#   curl -fsSL https://raw.githubusercontent.com/VM-development/ai-dev-kit/main/bootstrap.sh | bash
#
# Override the source repo / cache dir with ADK_REPO / ADK_DEST env vars.
#
set -euo pipefail

ADK_REPO="${ADK_REPO:-https://github.com/VM-development/ai-dev-kit.git}"
ADK_DEST="${ADK_DEST:-$HOME/.ai-dev-kit}"
TARGET="$(pwd)"

command -v git >/dev/null 2>&1 || { echo "git is required" >&2; exit 1; }

if [ -d "$ADK_DEST/.git" ]; then
  echo "Updating ai-dev-kit in $ADK_DEST…"
  git -C "$ADK_DEST" pull --ff-only || echo "(could not fast-forward; using existing copy)"
else
  echo "Cloning ai-dev-kit into $ADK_DEST…"
  git clone --depth 1 "$ADK_REPO" "$ADK_DEST"
fi

exec bash "$ADK_DEST/setup.sh" "$TARGET" "$@"
