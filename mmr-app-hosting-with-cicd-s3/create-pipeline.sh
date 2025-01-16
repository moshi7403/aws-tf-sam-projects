#!/bin/bash

# *** Change this to the desired name of the Cloudformation stack of
# your Pipeline (*not* the stack name of your app)
CODEPIPELINE_STACK_NAME="mmr-from-pipeline-sh"

if [ -z "${1:-}" ]; then
    echo "PIPELINE CREATION FAILED!"
    echo "Usage: $0 <GitHub OAuth Token>"
    exit 1
fi

GITHUB_OAUTH_TOKEN=$1

# Validate the template
if ! aws cloudformation validate-template --template-body file://template.yaml &>/dev/null; then
    echo "Template validation failed. Check your pipeline.yaml file."
    exit 1
fi

set -eu

aws cloudformation create-stack \
        --capabilities CAPABILITY_IAM CAPABILITY_AUTO_EXPAND \
        --stack-name "$CODEPIPELINE_STACK_NAME" \
        --parameters ParameterKey=AuthToken,ParameterValue=${GITHUB_OAUTH_TOKEN} \
        --template-body file://template.yaml