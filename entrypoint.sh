#!/bin/bash
set -euo pipefail

# Optional: align docker GID if host differs (pass DOCKER_GID via env/compose)
if [ -n "${DOCKER_GID:-}" ]; then
  if getent group docker >/dev/null 2>&1; then
    sudo groupmod -g "${DOCKER_GID}" docker || true
  else
    sudo groupadd -g "${DOCKER_GID}" docker || true
  fi
  sudo usermod -aG docker "${USER_CI:-ci}" || true
fi

# Make the socket group-writable
if [ -S /var/run/docker.sock ]; then
  sudo chmod g+rw /var/run/docker.sock || true
fi

exec "$@"

