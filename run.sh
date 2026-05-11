#!/bin/bash
set -euo pipefail

PROJECT_DIR="${1:-$PWD}"
shift || true

CLAUDE_HOME="${PROJECT_DIR}/claude_home"
mkdir -p "${CLAUDE_HOME}"

docker run \
  -it \
  --rm \
  --shm-size=256m \
  --cap-add NET_ADMIN \
  -v "${PROJECT_DIR}:/ext/project:rw" \
  -v "${CLAUDE_HOME}:/home/claude:rw" \
  --name claude-sandbox \
  "claude-sandbox:dev" \
  "$@"
