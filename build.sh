#!/bin/bash
set -euo pipefail

docker buildx build -t "koenighotze/claude-sandbox:dev" .