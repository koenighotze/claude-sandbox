#!/bin/bash
set -euo pipefail

PROJECT_DIR="$(realpath "${1:-$PWD}")"
shift || true

PROJECT_NAME="$(basename "$PROJECT_DIR")"
CLAUDE_HOME="${CLAUDE_SANDBOX_HOME:-${HOME}/.claude-sandbox/${PROJECT_NAME}}"
mkdir -p "${CLAUDE_HOME}"

CONTAINER_NAME="claude-sandbox-${PROJECT_NAME}"

docker run \
  -it \
  --rm \
  --shm-size=256m \
  --cap-add NET_ADMIN \
  --cap-add SYS_ADMIN \
  -v "${PROJECT_DIR}:/ext/project:rw" \
  -v "${CLAUDE_HOME}:/home/claude/.claude:rw" \
  --name "${CONTAINER_NAME}" \
  "claude-sandbox:dev" \
  "$@"
