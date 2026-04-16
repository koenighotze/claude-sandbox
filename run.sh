#!/bin/bash
set -euo pipefail

PROJECT_DIR="${1:-$PWD}"
shift || true

# Consume optional "--" separator before claude args
if [[ "${1:-}" == "--" ]]; then
  shift
fi

CONTAINER_NAME="claude-sandbox"
CLAUDE_HOME="${PROJECT_DIR}/claude_home"
mkdir -p "${CLAUDE_HOME}"

if docker ps -q --filter "name=^${CONTAINER_NAME}$" | grep -q .; then
  echo "Attaching to running container '${CONTAINER_NAME}'..."
  docker attach "${CONTAINER_NAME}"
else
  # Remove any stopped container with the same name before starting fresh
  docker rm "${CONTAINER_NAME}" 2>/dev/null || true

  # Forward common API keys and tokens if set in the host environment
  ENV_ARGS=()
  for var in ANTHROPIC_API_KEY GITHUB_TOKEN GH_TOKEN OPENAI_API_KEY; do
    [[ -n "${!var:-}" ]] && ENV_ARGS+=(-e "${var}")
  done

  # SYS_PTRACE and seccomp=unconfined weaken isolation; opt in explicitly
  UNSAFE_ARGS=()
  if [[ "${ENABLE_UNSAFE_CAPS:-}" == "1" ]]; then
    UNSAFE_ARGS+=(--cap-add SYS_PTRACE --security-opt seccomp=unconfined)
  fi

  docker run -it --name "${CONTAINER_NAME}" \
    --init \
    --cap-add NET_ADMIN \
    "${UNSAFE_ARGS[@]}" \
    --shm-size=256m \
    "${ENV_ARGS[@]}" \
    -v "${PROJECT_DIR}:/project:rw" \
    -v "${CLAUDE_HOME}:/home/claude:rw" \
    koenighotze/claude-sandbox:dev "$@"
fi