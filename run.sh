#!/bin/bash
set -euo pipefail

PROJECT_DIR="${1:-$PWD}"

docker run -it --name "claude-sandbox" \
  --cap-add NET_ADMIN \
  -v "${PROJECT_DIR}:/project:rw" \
  koenighotze/claude-sandbox:dev