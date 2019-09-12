#!/usr/bin/env bash

set -euo pipefail
set -o nounset

. ./commons.sh --source-only

cd $TF_TEMPLATE_WORKING_DIR

# Clear all previous plans
rm -f *.out
# Setting the scripts to be run as executable
chmod -f 752 *.sh || true

export ARM_ACCESS_KEY=$(storageAccountPrimaryKey)
export ARM_CLIENT_SECRET=$servicePrincipalKey
export ARM_CLIENT_ID=$servicePrincipalId
export ARM_TENANT_ID=$(azureTenantId)

TF_PLAN_FILE="${TF_WORKSPACE_NAME}_plan.out"
TF_CLI_ARGS=${TF_CLI_ARGS:-}

terraform plan "$TF_CLI_ARGS" -out "$TF_PLAN_FILE"
