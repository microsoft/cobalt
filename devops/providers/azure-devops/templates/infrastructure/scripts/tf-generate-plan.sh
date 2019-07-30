#!/usr/bin/env bash

set -euo pipefail

. ./commons.sh --source-only

printenv

cd $TF_TEMPLATE_WORKING_DIR

# Clear all previous plans
rm -f *.out
# Setting the scripts to be run as executable
chmod 752 *.sh

export ARM_ACCESS_KEY=$(storageAccountPrimaryKey)
export ARM_CLIENT_SECRET=$servicePrincipalKey
export ARM_CLIENT_ID=$servicePrincipalId
# export ARM_TENANT_ID=$(azureTenantId)

TF_PLAN_FILE="${TF_WORKSPACE_NAME}_plan.out"

terraform plan -out $TF_PLAN_FILE
