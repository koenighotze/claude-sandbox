#!/bin/bash
set -euo pipefail

CONTAINER_NAME="claude-sandbox"

if docker ps -aq --filter "name=^${CONTAINER_NAME}$" | grep -q .; then
  docker rm -f "${CONTAINER_NAME}"
  echo "Container '${CONTAINER_NAME}' removed."
else
  echo "No container '${CONTAINER_NAME}' found."
fi
