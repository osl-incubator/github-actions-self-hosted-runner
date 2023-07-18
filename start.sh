#!/usr/bin/env bash

REPOSITORY=$REPO
ACCESS_TOKEN=$GH_TOKEN

echo "REPO ${REPOSITORY}"
echo "ACCESS_TOKEN ${ACCESS_TOKEN}"

GITHUB_REGISTRATION_URL=https://api.github.com/repos/${REPOSITORY}/actions/runners/registration-token

REG_TOKEN=$(curl -X POST -H "Authorization: token ${ACCESS_TOKEN}" -H "Accept: application/vnd.github+json" ${GITHUB_REGISTRATION_URL} | jq .token --raw-output)

cd $HOME/actions-runner

./config.sh --url https://github.com/${REPOSITORY} --token ${REG_TOKEN}

cleanup() {
    echo "Removing runner..."
    ./config.sh remove --unattended --token ${REG_TOKEN}
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

./run.sh & wait $!
