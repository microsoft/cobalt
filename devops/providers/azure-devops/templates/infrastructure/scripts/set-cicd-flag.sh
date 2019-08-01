#!/usr/bin/env bash

# Note: Omitting `set -euo pipefail` as it makes using grep to filter for changes a nightmare!

declare readonly GIT_DIFF_EXTENSION_WHITE_LIST="*.go|*.tf|*.sh|Dockerfile*|*.tfvars"

function setCICDFlag() {
    echo "Template $TERRAFORM_TEMPLATE_PATH needs CI/CD"
    echo "##vso[task.setvariable variable=needs_cicd;isOutput=true]true"
}

MASTER="remotes/origin/master"
GIT_DIFF_SOURCEBRANCH="HEAD"

# we should always use master as a comparison, except in the case that this is
# a build for master. In this case we can use HEAD~ (1 commit behind master)
# because all merges will be squash merges
if [[ $(git diff "$MASTER") ]]; then
    GIT_DIFF_UPSTREAMBRANCH="$MASTER"
else
    GIT_DIFF_UPSTREAMBRANCH="$MASTER~"
fi

echo "GIT_DIFF_UPSTREAMBRANCH: $GIT_DIFF_UPSTREAMBRANCH"
echo "GIT_DIFF_SOURCEBRANCH: $GIT_DIFF_SOURCEBRANCH"

FILE_CHANGE_SET=$(git diff $GIT_DIFF_SOURCEBRANCH $GIT_DIFF_UPSTREAMBRANCH --name-only)
echo "Files changed since last commit..."
echo $FILE_CHANGE_SET

FILTERED_FILE_CHANGE_SET=$(grep -E "$GIT_DIFF_EXTENSION_WHITE_LIST" <<< "$FILE_CHANGE_SET" || true)
echo "Files changed since last commit, filtered for build-relevant files..."
echo $FILTERED_FILE_CHANGE_SET

TEST_HARNESS_CHANGES=$(grep "$TEST_HARNESS_DIR" <<< "$FILTERED_FILE_CHANGE_SET" || true)
echo "A..."
echo $TEST_HARNESS_CHANGES

TEMPLATE_CHANGES=$(grep "$TERRAFORM_TEMPLATE_PATH" <<< "$FILTERED_FILE_CHANGE_SET" || true)
echo "B..."
echo $TEMPLATE_CHANGES

MODULE_CHANGES=$(grep "$TF_ROOT_DIR/modules" <<< "$FILTERED_FILE_CHANGE_SET" || true)
echo "C..."
echo $MODULE_CHANGES

# if relevant files have been changed, CICD for this template needs to run
[ ! -z "${TEST_HARNESS_CHANGES}" ] && setCICDFlag
echo "D..."
[ ! -z "${TEMPLATE_CHANGES}" ] && setCICDFlag
echo "E..."
[ ! -z "${MODULE_CHANGES}" ] && setCICDFlag
echo "F..."
