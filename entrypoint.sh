#!/usr/bin/env bash
set -euo pipefail

sudo mkdir -p /var/log
sudo chmod 777 /var/log

sudo dockerd --host=unix:///var/run/docker.sock > /var/log/dockerd.log 2>&1 &

# wait for the engine
for i in $(seq 1 60); do
  if docker info >/dev/null 2>&1; then
    break
  fi
  sleep 1
  if [ "$i" -eq 60 ]; then
    echo "dockerd did not become ready. Last log lines:" >&2
    tail -n 100 /var/log/dockerd.log >&2
    exit 1
  fi
done

exec "$@"
