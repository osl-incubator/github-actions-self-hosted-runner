FROM ubuntu:23.04

# Prevents installdependencies.sh from prompting the user and blocking the image creation
ARG DEBIAN_FRONTEND=noninteractive

RUN apt update -y && apt upgrade -y && useradd -m docker
RUN apt install -y --no-install-recommends \
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
  sudo

ENV RUNNER_VERSION="2.306.0"

RUN cd /home/docker && mkdir actions-runner && cd actions-runner \
  && echo "docker ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/docker \
  && chmod 0440 /etc/sudoers.d/docker \
  && curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
  && tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
  && echo "b0a090336f0d0a439dac7505475a1fb822f61bbb36420c7b3b3fe6b1bdc4dbaa  actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz" | shasum -a 256 -c

RUN chown -R docker ~docker && /home/docker/actions-runner/bin/installdependencies.sh

COPY start.sh start.sh

# make the script executable
RUN chmod +x start.sh

# since the config and run script for actions are not allowed to be run by root,
# set the user to "docker" so all subsequent commands are run as the docker user
USER docker

ENTRYPOINT ["./start.sh"]
