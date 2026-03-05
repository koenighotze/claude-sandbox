#!/bin/bash
set -euo pipefail

PROJECT_DIR="${1:-$PWD}"

docker run -it --name "claude-sandbox" \
  -v "${PROJECT_DIR}:/project:rw" \
  koenighotze/claude-sandbox:dev