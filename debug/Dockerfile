FROM ubuntu:23.04

# Prevents installdependencies.sh from prompting the user and blocking the image creation
ARG DEBIAN_FRONTEND=noninteractive

RUN apt update -y \
  && apt upgrade -y \
  && apt install -y --no-install-recommends \
    curl \
    jq \
    build-essential \
    libssl-dev \
    libffi-dev \
    python3 \
    python3-venv \
    python3-dev \
    python3-pip \
    git \
    sudo \
    ca-certificates \
    gnupg \
  && install -m 0755 -d /etc/apt/keyrings \
  && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
  && chmod a+r /etc/apt/keyrings/docker.gpg \
  && echo \
    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null \
  && apt-get update \
  && apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin \
  && rm -rf /var/lib/apt/lists/* \
    /var/cache/apt/archives \
    /tmp/*

ENV USER_CI=ci

RUN useradd -ms /bin/bash $USER_CI \
  && usermod -aG docker $USER_CI \
  && newgrp docker \
  && mkdir -p /home/$USER_CI/actions-runner \
  && echo "$USER_CI ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$USER_CI \
  && chmod 0440 /etc/sudoers.d/$USER_CI

# since the config and run script for actions are not allowed to be run by root,
# set the user to "docker" so all subsequent commands are run as the docker user
USER $USER_CI

COPY --chown=$USER_CI:$USER_CI entrypoint.sh /tmp/entrypoint.sh

ENTRYPOINT ["/tmp/entrypoint.sh"]
CMD ["docker", "run", "--rm", "hello-world"]
