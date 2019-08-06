#!/usr/bin/env bash

set -euo pipefail

. ./commons.sh --source-only

terraformVersionCheck

cd "$BUILD_SOURCESDIRECTORY"

echo "Linting Terraform Files... If this fails, run 'terraform fmt -recursive' to fix"
terraform fmt -recursive -check
