#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
CONTAINER_ENGINE="${CONTAINER_ENGINE:-podman}"
IMAGE_NAME="chezmoi-dotfiles-validate"

echo "==> Building validation container from local source"
echo "    Engine: ${CONTAINER_ENGINE}"

"$CONTAINER_ENGINE" build \
    -t "$IMAGE_NAME" \
    -f "$SCRIPT_DIR/Containerfile" \
    "$REPO_DIR"

echo "==> Validation passed: container built successfully"
echo "    To inspect: ${CONTAINER_ENGINE} run -it ${IMAGE_NAME} bash -l"
