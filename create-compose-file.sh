touch .env
export $(cat .env)
envsubst < docker-compose.yaml.tpl > docker-compose.yaml
