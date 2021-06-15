#!/bin/bash
set -ex

DIR="$(dirname $0)"
COMPOSE_FILES_FOLDER="${DIR}/gitlab"
COMPOSE_FILES_AS_PARAMS="01-postgresql.yml -f 02-redis.yml -f 03-gitaly.yml -f 04-gitlab.yml -f 05-ingress.yml -f 06-sidekiq.yml"

ENV_FILE=config/global/config.env
ENV_FILE_FULL_PATH="${COMPOSE_FILES_FOLDER}/${ENV_FILE}"
if [[ ! -f ${ENV_FILE_FULL_PATH} ]]; then
	echo "Copy from template..."
	cp ${COMPOSE_FILES_FOLDER}/config/global/config.template.env ${ENV_FILE_FULL_PATH}
fi

(cd ${COMPOSE_FILES_FOLDER} && echo $(pwd) && docker-compose --env-file ${ENV_FILE} -f ${COMPOSE_FILES_AS_PARAMS} up -d) || echo "Failed to run compose"
