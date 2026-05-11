#!/bin/bash
set -euo pipefail

CLAUDE_HOME="${HOME}/.claude"
mkdir -p "${CLAUDE_HOME}"

SETTINGS="${CLAUDE_HOME}/settings.json"
if [ ! -f "${SETTINGS}" ]; then
  cp /etc/claude-defaults/settings.json "${SETTINGS}"
  echo "[entrypoint] settings.json seeded from defaults"
else
  echo "[entrypoint] settings.json already exists, skipping"
fi

STATUSLINE="${CLAUDE_HOME}/statusline.sh"
if [ ! -f "${STATUSLINE}" ]; then
  cp /etc/claude-defaults/statusline.sh "${STATUSLINE}"
  echo "[entrypoint] statusline.sh seeded from defaults"
else
  echo "[entrypoint] statusline.sh already exists, skipping"
fi


SKILL="${CLAUDE_HOME}/skills/get-api-docs"
if [ ! -e "${SKILL}" ]; then
  mkdir -p "$(dirname "${SKILL}")"
  ln -s "${NPM_CONFIG_PREFIX}/lib/node_modules/@aisuite/chub/skills/get-api-docs" "${SKILL}"
  echo "[entrypoint] skill get-api-docs linked"
else
  echo "[entrypoint] skill get-api-docs already exists, skipping"
fi

exec claude "$@"
