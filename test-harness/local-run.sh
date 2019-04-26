# NAME: local-run.sh
# DESCRIPTION: 
# Builds and runs the test harness container. This container runs all build target tasks on the 
# host machine. These targets include mage clean, format, unit and integration tests.
# This base image also pre-installs the golang vendor
# USAGE: ./test-harness/local-run.sh

#!/usr/bin/env bash
set -euo pipefail
. ./test-harness/init.sh --source-only

readonly BUILD_SOURCEBRANCHNAME=`git branch | sed -n '/\* /s///p'`
readonly BUILD_UPSTREAMBRANCH="master"
readonly TF_STATE_STORAGE_ACCT="cobaltfstate"
readonly TF_STATE_CONTAINER="cobaltfstate-remote-state-container"
readonly docker_base_image_name="msftcse/cobalt-test-base"

function dotenv() {
    set -a
    [ -f .env ] && . .env
    set +a
}

function run_test_harness() {
    echo "INFO: loading environment"
    dotenv
    check_required_env_variables
    docker_base_image_tag="g${GO_VERSION}t${TF_VERSION}"
    echo "INFO: verified that environment is fully defined"
    build_test_harness $BUILD_UPSTREAMBRANCH \
                       $BUILD_SOURCEBRANCHNAME \
                       "$docker_base_image_name:$docker_base_image_tag"
    run_test_image
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