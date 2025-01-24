FROM ubuntu:24.04

# Prevents installdependencies.sh from prompting the user and blocking the image creation
ARG DEBIAN_FRONTEND=noninteractive
ARG HTTP_PROXY
ARG HTTPS_PROXY
ARG NO_PROXY

USER root

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
  && echo "$USER_CI ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$USER_CI \
  && chmod 0440 /etc/sudoers.d/$USER_CI

# Using echo and tee to append the variables to /etc/environment
RUN echo "http_proxy=\"$HTTP_PROXY\"" | tee -a /etc/environment && \
    echo "https_proxy=\"$HTTPS_PROXY\"" | tee -a /etc/environment && \
    echo "no_proxy=\"$NO_PROXY\"" | tee -a /etc/environment

# since the config and run script for actions are not allowed to be run by root,
# set the user to "docker" so all subsequent commands are executed as the docker user
USER $USER_CI

ENV RUNNER_VERSION=2.309.0
ENV RUNNER_SHA256=2974243bab2a282349ac833475d241d5273605d3628f0685bd07fb5530f9bb1a
ENV USER_CI=ci

RUN mkdir -p ${HOME}/actions-runner \
  && cd ${HOME}/actions-runner \
  && export RUNNER_PKG="actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz" \
  && export RUNNER_URL="https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/${RUNNER_PKG}" \
  && curl -O -L "${RUNNER_URL}" \
  && echo "${RUNNER_SHA256}  ${RUNNER_PKG}" | shasum -a 256 -c \
  && tar xzf "./${RUNNER_PKG}"

COPY start.sh start.sh
RUN sudo chmod +x start.sh

# COPY post-install.sh post-install.sh
# RUN sudo chmod +x post-install.sh \
#   && ./post-install.sh

COPY --chown=$USER_CI:$USER_CI entrypoint.sh /tmp/entrypoint.sh

ENTRYPOINT ["/tmp/entrypoint.sh"]
CMD ["./start.sh"]
