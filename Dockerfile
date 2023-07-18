FROM mambaorg/micromamba:lunar

# Prevents installdependencies.sh from prompting the user and blocking the image creation
ARG DEBIAN_FRONTEND=noninteractive

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
    git

RUN groupadd docker || true \
  && usermod -aG docker $MAMBA_USER \
  && newgrp docker

USER $MAMBA_USER

ENV RUNNER_VERSION="2.306.0"

RUN cd /home/$MAMBA_USER && mkdir actions-runner && cd actions-runner \
  && curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
  && tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
  && echo "b0a090336f0d0a439dac7505475a1fb822f61bbb36420c7b3b3fe6b1bdc4dbaa  actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz" | shasum -a 256 -c


USER root
RUN /home/$MAMBA_USER/actions-runner/bin/installdependencies.sh


COPY --chown=$MAMBA_USER:$MAMBA_USER start.sh start.sh

# make the script executable
RUN chmod +x start.sh

USER $MAMBA_USER


# since the config and run script for actions are not allowed to be run by root,
# set the user to "docker" so all subsequent commands are run as the docker user

ENTRYPOINT ["./start.sh"]
