#!/usr/bin/env bash

set -euo pipefail

. ./commons.sh --source-only

terraformVersionCheck

cd $TF_TEMPLATE_WORKING_DIR

pwd
ls

# Setting the scripts to be run as executable
chmod -R 752 .terraform

export ARM_ACCESS_KEY=$(storageAccountPrimaryKey)

terraform init -backend-config "storage_account_name=$TF_VAR_remote_state_account" -backend-config "container_name=$TF_VAR_remote_state_container"
terraform workspace new $TF_WORKSPACE_NAME || terraform workspace select $TF_WORKSPACE_NAME
