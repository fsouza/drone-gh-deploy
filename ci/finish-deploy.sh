#!/bin/sh -e

SCRIPT_DIR=$(cd $(dirname $0); pwd -P)
source ${SCRIPT_DIR}/common.sh

# This scripts adds the environmentUrl to the deployment.

function find_deployment() {
    hub api graphql \
        -F query=@${SCRIPT_DIR}/queries/get-repo-deployment.graphql \
        -F owner=${DRONE_REPO_OWNER} \
	-F name=${DRONE_REPO_NAME} \
        -F environment=${DRONE_DEPLOY_TO} \
        | node ${SCRIPT_DIR}/transform-deploy-data.js
}

deploy_data="$(find_deployment $1)"

echo "DEPLOY DATA: $deploy_data"
if [ -n "$deploy_data" ]; then
    hub api graphql \
        -H "Accept: application/vnd.github.flash-preview+json" \
        -F query=@${SCRIPT_DIR}/queries/create-deployment-status.graphql \
        -F deploymentId=$(echo "$deploy_data" | jq -r .id) \
        -F description="Adding environmentUrl" \
        -F logUrl=$(echo "$deploy_data" | jq -r .logUrl) \
        -F state=SUCCESS
fi
