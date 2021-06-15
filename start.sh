#!/bin/bash
set -ex

DIR="$(dirname $0)"
COMPOSE_FILES_FOLDER="${DIR}/gitlab"
COMPOSE_FILES_AS_PARAMS="01-postgresql.yml -f 02-redis.yml -f 03-gitaly.yml -f 04-gitlab.yml -f 05-ingress.yml -f 06-sidekiq.yml"

GLOBAL_CONFIG_FOLDER_REL="config/global"
GLOBAL_CONFIG_FOLDER_ABS="${COMPOSE_FILES_FOLDER}/${GLOBAL_CONFIG_FOLDER_REL}"
ENV_FILE=config.env
ENV_FILE_FULL_PATH="${GLOBAL_CONFIG_FOLDER_ABS}/${ENV_FILE}"
GITLAB_SECRETS_FULL_PATH="${GLOBAL_CONFIG_FOLDER_ABS}/gitlab-secrets.json"

if [[ ! -f ${ENV_FILE_FULL_PATH} ]]; then
	echo "Copy config.template.env"
	cp ${COMPOSE_FILES_FOLDER}/${GLOBAL_CONFIG_FOLDER_REL}/config.template.env ${ENV_FILE_FULL_PATH}
fi

if [[ ! -f ${GITLAB_SECRETS_FULL_PATH} ]]; then
	echo "Copy gitlab-secrets.template.json"
	cp ${COMPOSE_FILES_FOLDER}/${GLOBAL_CONFIG_FOLDER_REL}/gitlab-secrets.template.json ${GITLAB_SECRETS_FULL_PATH}
fi

# Generate ssh host key for the first time
GITLAB_SSH_HOST_RSA_KEY="${GLOBAL_CONFIG_FOLDER_ABS}/ssh_host_rsa_key"
if [[ ! -f ${GITLAB_SSH_HOST_RSA_KEY}  ]]; then
	echo "Generating ssh_host_rsa_key..."
	ssh-keygen -f ${GITLAB_SSH_HOST_RSA_KEY} -N '' -t rsa
	chmod 0600 ${GITLAB_SSH_HOST_RSA_KEY}
fi

GITLAB_SSH_HOST_ECDSA_KEY="${GLOBAL_CONFIG_FOLDER_ABS}/ssh_host_ecdsa_key"
if [[ ! -f ${GITLAB_SSH_HOST_ECDSA_KEY} ]]; then
	echo "Generating ssh_host_ecdsa_key..."
	ssh-keygen -f ${GITLAB_SSH_HOST_ECDSA_KEY} -N '' -t ecdsa
	chmod 0600 ${GITLAB_SSH_HOST_ECDSA_KEY}
fi

GITLAB_SSH_HOST_ED25519_KEY="${GLOBAL_CONFIG_FOLDER_ABS}/ssh_host_ed25519_key"
if [[ ! -f ${GITLAB_SSH_HOST_ED25519_KEY} ]]; then
	echo "Generating ssh_host_ed25519_key..."
	ssh-keygen -f ${GITLAB_SSH_HOST_ED25519_KEY} -N '' -t ed25519
	chmod 0600 ${GITLAB_SSH_HOST_ED25519_KEY}
fi

source ${ENV_FILE_FULL_PATH}
mkdir -p ${GITLAB_DATA_FOLDER}

(cd ${COMPOSE_FILES_FOLDER} && echo $(pwd) && docker-compose --env-file ${GLOBAL_CONFIG_FOLDER_REL}/${ENV_FILE} -f ${COMPOSE_FILES_AS_PARAMS} up -d) || echo "Failed to run compose"
