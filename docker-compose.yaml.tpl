version: "3.8"
services:
  runner:
    build:
      dockerfile: Dockerfile
      context: .
      args:
        HTTP_PROXY: "${HTTP_PROXY}"
        HTTPS_PROXY: "${HTTPS_PROXY}"
        NO_PROXY: "${NO_PROXY}"
    runtime: sysbox-runc
    restart: always
    env_file: .env
    deploy:
      mode: replicated
      replicas: ${DOCKER_REPLICAS}
      resources:
        limits:
          cpus: ${DOCKER_LIMITS_CPUS}
          memory: ${DOCKER_LIMITS_MEMORY}
        reservations:
          cpus: ${DOCKER_RESERVATIONS_CPUS}
          memory: ${DOCKER_RESERVATIONS_MEMORY}


