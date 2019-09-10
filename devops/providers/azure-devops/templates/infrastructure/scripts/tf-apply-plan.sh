#!/usr/bin/env bash

set -euo pipefail

. ./commons.sh --source-only

terraformVersionCheck

cd $TF_TEMPLATE_WORKING_DIR

# Setting the scripts to be run as executable
chmod -R 752 .terraform

export ARM_ACCESS_KEY=$(storageAccountPrimaryKey)
export ARM_CLIENT_SECRET=$servicePrincipalKey
export ARM_CLIENT_ID=$servicePrincipalId
export ARM_TENANT_ID=$(azureTenantId)

TF_PLAN_FILE="${TF_WORKSPACE_NAME}_plan.out"

terraform apply $TF_CLI_ARGS -auto-approve $TF_PLAN_FILE
