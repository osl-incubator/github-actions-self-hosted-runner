#!/usr/bin/env bash
set -euo pipefail

: "${GH_REPO:?GH_REPO (owner/repo) is required}"
: "${GH_TOKEN:?GH_TOKEN is required}"

# Pick a runner dir that exists
if [ -d "${HOME}/actions-runner" ]; then
  RUNNER_DIR="${HOME}/actions-runner"
elif [ -d "/home/ci/actions-runner" ]; then
  RUNNER_DIR="/home/ci/actions-runner"
else
  echo "ERROR: actions-runner directory not found under \$HOME (${HOME}) or /home/ci" >&2
  ls -la "${HOME}" || true
  exit 1
fi

cd "${RUNNER_DIR}"

RUNNER_NAME="${RUNNER_NAME:-$(hostname)}"
RUNNER_LABELS="${RUNNER_LABELS:-self-hosted,linux,x64}"
RUNNER_GROUP="${RUNNER_GROUP:-Default}"
RUNNER_WORK="${RUNNER_WORK:-_work}"
GITHUB_API="${GITHUB_API:-https://api.github.com}"
REPO_URL="https://github.com/${GH_REPO}"

cd "${RUNNER_DIR}"

need() { command -v "$1" >/dev/null 2>&1 || { echo "Missing dependency: $1" >&2; exit 1; }; }
need curl
need jq

echo "Registering runner for ${GH_REPO} as '${RUNNER_NAME}' (group: ${RUNNER_GROUP}, labels: ${RUNNER_LABELS})"

# 1) Get a short-lived registration token
REG_TOKEN="$(
  curl -fsSL \
    -X POST \
    -H "Authorization: token ${GH_TOKEN}" \
    -H "Accept: application/vnd.github+json" \
    --retry 5 --retry-delay 2 --max-time 30 \
    "${GITHUB_API}/repos/${GH_REPO}/actions/runners/registration-token" \
  | jq -r '.token'
)"

if [[ -z "${REG_TOKEN}" || "${REG_TOKEN}" == "null" ]]; then
  echo "Failed to obtain registration token from GitHub API." >&2
  exit 1
fi

# 2) Configure the runner (idempotent via --replace)
./config.sh \
  --unattended \
  --replace \
  --name "${RUNNER_NAME}" \
  --url  "${REPO_URL}" \
  --token "${REG_TOKEN}" \
  --labels "${RUNNER_LABELS}" \
  --runnergroup "${RUNNER_GROUP}" \
  --work "${RUNNER_WORK}"

# Cleanup handler (uses the same token; valid for a short time)
cleanup() {
  echo "Removing runner '${RUNNER_NAME}' from ${GH_REPO}..."
  set +e
  ./config.sh remove --unattended --token "${REG_TOKEN}"
}
trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

# 3) Run the runner (foreground)
exec ./run.sh
