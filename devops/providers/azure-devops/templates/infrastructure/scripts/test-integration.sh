#!/usr/bin/env bash

set -euo pipefail

. ./commons.sh --source-only

export ARM_ACCESS_KEY=$(storageAccountPrimaryKey)
export ARM_CLIENT_SECRET=$servicePrincipalKey
export ARM_CLIENT_ID=$servicePrincipalId
export ARM_TENANT_ID=$(azureTenantId)

cd $ARTIFACT_ROOT/$TERRAFORM_TEMPLATE_PATH

# Setting the scripts to be run as executable
chmod -fR 755 *.sh || true

go test $(go list ./... | grep "$TERRAFORM_TEMPLATE_PATH" | grep "integration")
