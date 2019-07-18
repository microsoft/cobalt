#!/usr/bin/env bash

set -euo pipefail

. "$BUILD_SOURCESDIRECTORY"/cicd/commons.sh --source-only

dockerLogin

BASE_IMAGE="$BASE_IMAGE_ACR_NAME".azurecr.io/"$TEST_HARNESS_BASE_IMAGE":g${GO_VERSION}t${TF_VERSION}

rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
cp -r ./infra/ "$BUILD_DIR"
cp -r "$TEST_HARNESS_DIR"/* "$BUILD_DIR"
cp go.* "$BUILD_DIR"

docker build                                 \
    --rm                                     \
    --file "$TEST_HARNESS_DIR/Dockerfile"    \
    --build-arg build_directory="$BUILD_DIR"   \
    --build-arg base_image="$BASE_IMAGE"       \
    --tag $(testHarnessBuildArtifactName)    \
    .

echo "Test Harness Built!"
