#!/bin/bash
set -euo pipefail

# Auto-detect host architecture; override with PLATFORM=linux/amd64 ./build.sh
ARCH=$(uname -m)
case "${ARCH}" in
  arm64|aarch64) DEFAULT_PLATFORM="linux/arm64" ;;
  *)             DEFAULT_PLATFORM="linux/amd64" ;;
esac
PLATFORM="${PLATFORM:-${DEFAULT_PLATFORM}}"

docker buildx build --platform "${PLATFORM}" -t "koenighotze/claude-sandbox:dev" .