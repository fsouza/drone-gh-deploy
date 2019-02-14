#!/bin/sh -e

function pr_branch() {
    test -n "${DRONE_PULL_REQUEST}"
    test -n "${DRONE_COMMIT_REFSPEC}"
    echo $DRONE_COMMIT_REFSPEC | grep -o '^[^:]\+'
}

function environment_name() {
    environment=${1}
    if [ "$environment" = "preview" ] && [ -n "$DRONE_PULL_REQUEST" ]; then
        branch=$(pr_branch)
        if echo "$branch" | grep -q ^preview-; then
            environment="$branch"
        else
            environment="preview-${branch}"
        fi
    fi
    echo "$environment"
}
