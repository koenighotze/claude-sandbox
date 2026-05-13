#!/bin/bash
set -euo pipefail

PROJECT_DIR="$(realpath "${1:-$PWD}")"
PROJECT_NAME="$(basename "$PROJECT_DIR")"
CONTAINER_NAME="claude-sandbox-${PROJECT_NAME}"

if docker ps -aq --filter "name=^${CONTAINER_NAME}$" | grep -q .; then
  docker rm -f "${CONTAINER_NAME}"
  echo "Container '${CONTAINER_NAME}' removed."
else
  echo "No container '${CONTAINER_NAME}' found."
fi
