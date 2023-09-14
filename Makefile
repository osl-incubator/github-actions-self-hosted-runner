DOCKER_COMPOSE=docker compose --env-file .env

build:
	${DOCKER_COMPOSE} build

start:
	${DOCKER_COMPOSE} up -d

stop:
	${DOCKER_COMPOSE} stop

rm:
	${DOCKER_COMPOSE} rm --stop

sysbox-restart:
	sudo service docker stop && sudo service sysbox stop
	sudo service sysbox start && sudo service docker start
