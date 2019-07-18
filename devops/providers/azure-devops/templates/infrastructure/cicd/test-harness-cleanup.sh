#!/usr/bin/env bash

set -euo pipefail

. "$BUILD_SOURCESDIRECTORY/cicd/commons.sh" --source-only

IMAGE_TO_REMOVE=$(testHarnessBuildArtifactName)
docker image rm --force $(docker image ls $IMAGE_TO_REMOVE -q)
