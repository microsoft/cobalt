# NAME: local-run.sh
# DESCRIPTION: 
# Builds and runs the test harness container. This container runs all build target tasks on the 
# host machine. These targets include mage clean, format, unit and integration tests.
# USAGE: ./test-harness/local-run.sh

#!/usr/bin/env bash
set -euo pipefail
. ./test-harness/init.sh --source-only

readonly BUILD_SOURCEBRANCHNAME=`git branch | sed -n '/\* /s///p'`
readonly BUILD_TEMPLATE_DIRS="build"
readonly BUILD_TEST_RUN_IMAGE="cobalt-test-harness"
readonly BUILD_UPSTREAMBRANCH="master"
readonly TF_STATE_STORAGE_ACCT="cobaltfstate"
readonly TF_STATE_CONTAINER="cobaltfstate-remote-state-container"
readonly BUILD_BUILDID=1

function dotenv() {
    set -a
    [ -f .env ] && . .env
    set +a
}

function run_test_harness() {
    echo "INFO: loading environment"
    dotenv
    check_required_env_variables
    echo "INFO: verified that environment is fully defined"
    template_build_targets $BUILD_UPSTREAMBRANCH $BUILD_SOURCEBRANCHNAME
    template_dirs=$( IFS=$' '; echo "${TEST_RUN_MAP[*]}" )
    echo "INFO: Running local build for templates: $template_dirs"
    mkdir $BUILD_TEMPLATE_DIRS && cp -r $template_dirs *.go $BUILD_TEMPLATE_DIRS

    echo "INFO: Building test harness image"
    rebuild_test_image
    rm -r $BUILD_TEMPLATE_DIRS
    run_test_image
}

function rebuild_test_image() {
    declare docker_base_img_tag="g${GO_VERSION}t${TF_VERSION}"
    echo "INFO: Using base image tag $docker_base_img_tag"
    docker build --rm -f "test-harness\Dockerfile" \
        -t $BUILD_TEST_RUN_IMAGE:$BUILD_BUILDID . \
        --build-arg build_directory="$BUILD_TEMPLATE_DIRS" \
        --build-arg base_img_tag="$docker_base_img_tag"
}

function run_test_image() {
    echo "INFO: Running test harness container"
    docker run -e ARM_SUBSCRIPTION_ID=$ARM_SUBSCRIPTION_ID \
            -e ARM_CLIENT_ID=$ARM_CLIENT_ID \
            -e ARM_CLIENT_SECRET=$ARM_CLIENT_SECRET \
            -e ARM_TENANT_ID=$ARM_TENANT_ID \
            -e DATACENTER_LOCATION=$DATACENTER_LOCATION \
            -e TF_STATE_STORAGE_ACCT=$TF_STATE_STORAGE_ACCT \
            -e TF_STATE_CONTAINER=$TF_STATE_CONTAINER \
            -e ARM_ACCESS_KEY=$ARM_ACCESS_KEY \
            --rm $BUILD_TEST_RUN_IMAGE:$BUILD_BUILDID

    echo "INFO: Completed test run"
}

run_test_harness