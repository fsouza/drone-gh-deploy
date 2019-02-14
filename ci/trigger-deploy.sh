#!/bin/sh -e

SCRIPT_DIR=$(cd $(dirname $0); pwd -P)
source ${SCRIPT_DIR}/common.sh

environment=$(environment_name ${1})

function get_repo_data() {
    query_type=push
    if [ "${DRONE_BUILD_EVENT}" = "pull_request" ]; then
        query_type=${DRONE_BUILD_EVENT}
    fi
    hub api graphql \
        -F query=@${SCRIPT_DIR}/queries/get-repo-${query_type}.graphql \
        -F owner=${DRONE_REPO_OWNER} \
        -F name=${DRONE_REPO_NAME} \
        -F refName=${DRONE_COMMIT_REF} \
        -F pullRequest=${DRONE_PULL_REQUEST:-0}
}

set +e
node /usr/src/check-for-pr/index.js
status=$?
set -e

if [ "$status" = "0" ]; then
    repo_data="$(get_repo_data)"
    repo_id=$(echo "$repo_data" | jq -r .data.repository.id)
    ref_id=$(echo "$repo_data" | jq -r 'if .data.repository.ref then .data.repository.ref.id else .data.repository.pullRequest.headRef.id end')

    auto_merge=true
    if [ "$environment" = "prd" ]; then
        auto_merge=false
    fi

    hub api graphql \
        -H "Accept: application/vnd.github.flash-preview+json" \
        -F query=@${SCRIPT_DIR}/queries/create-deployment.graphql \
        -F environment=$environment \
        -F description="${DRONE_COMMIT_MESSAGE}" \
        -F refId=$ref_id \
        -F repositoryId=$repo_id \
	-F autoMerge=$auto_merge
else
    echo "won't trigger deployment"
fi
