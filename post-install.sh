#!/usr/bin/env bash
# Check if HTTP_PROXY, HTTPS_PROXY, or NO_PROXY environment variables are set and configure Docker service accordingly.

set -ex

# Initialize variables
HTTP_PROXY=${HTTP_PROXY:-}
HTTPS_PROXY=${HTTPS_PROXY:-}
NO_PROXY=${NO_PROXY:-}

# Create ~/.docker directory if not exists
mkdir -p ~/.docker

# Create initial empty JSON
echo '{}' > ~/.docker/config.json

# Function to add proxy settings using jq
add_proxy() {
  local config_path=~/.docker/config.json
  local key=$1
  local value=$2

  jq --arg k "$key" --arg v "$value" \
  '.proxies.default[$k] = $v' $config_path > "$config_path.tmp" && \
  mv "$config_path.tmp" $config_path
}

# Add proxy settings to ~/.docker/config.json
if [[ -n "$HTTP_PROXY" ]]; then
  add_proxy "httpProxy" "$HTTP_PROXY"
fi

if [[ -n "$HTTPS_PROXY" ]]; then
  add_proxy "httpsProxy" "$HTTPS_PROXY"
fi

if [[ -n "$NO_PROXY" ]]; then
  add_proxy "noProxy" "$NO_PROXY"
fi

# Show the final config
cat ~/.docker/config.json

