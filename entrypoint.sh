#!/bin/bash
set -euo pipefail

SETTINGS="${HOME}/.claude/settings.json"
if [ ! -f "${SETTINGS}" ]; then
  mkdir -p "$(dirname "${SETTINGS}")"
  cp /etc/claude-defaults/settings.json "${SETTINGS}"
fi

exec claude --enable-auto-mode "$@"
