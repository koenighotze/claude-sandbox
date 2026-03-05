#!/bin/bash
set -euo pipefail

PROJECT_DIR="${1:-$PWD}"
shift || true

# Consume optional "--" separator before claude args
if [[ "${1:-}" == "--" ]]; then
  shift
fi

CONTAINER_NAME="claude-sandbox"

if docker ps -q --filter "name=^${CONTAINER_NAME}$" | grep -q .; then
  echo "Attaching to running container '${CONTAINER_NAME}'..."
  docker attach "${CONTAINER_NAME}"
else
  # Remove any stopped container with the same name before starting fresh
  docker rm "${CONTAINER_NAME}" 2>/dev/null || true
  docker run -it --name "${CONTAINER_NAME}" \
    --cap-add NET_ADMIN \
    -v "${PROJECT_DIR}:/project:rw" \
    koenighotze/claude-sandbox:dev "$@"
fi