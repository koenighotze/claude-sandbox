#!/bin/bash
set -euo pipefail

PROJECT_DIR="$(realpath "${1:-$PWD}")"
shift || true

PROJECT_NAME="$(basename "$PROJECT_DIR")"

# Base dir for all sandbox state. Auth is shared across projects; config is per-project.
SANDBOX_BASE="${CLAUDE_SANDBOX_HOME:-${HOME}/.claude-sandbox}"
CLAUDE_CONFIG="${SANDBOX_BASE}/${PROJECT_NAME}"
CLAUDE_AUTH="${SANDBOX_BASE}/.claude.json"

mkdir -p "${CLAUDE_CONFIG}"
# touch ensures the host path is a file before Docker bind-mounts it
touch "${CLAUDE_AUTH}"

CONTAINER_NAME="claude-sandbox-${PROJECT_NAME}"

docker run \
  -it \
  --rm \
  --shm-size=256m \
  --cap-add NET_ADMIN \
  --cap-add SYS_ADMIN \
  -v "${PROJECT_DIR}:/ext/project:rw" \
  -v "${CLAUDE_CONFIG}:/home/claude/.claude:rw" \
  -v "${CLAUDE_AUTH}:/home/claude/.claude.json:rw" \
  --name "${CONTAINER_NAME}" \
  "claude-sandbox:dev" \
  "$@"
