#!/usr/bin/env bash

set -euo pipefail

. "$BUILD_SOURCESDIRECTORY/cicd/commons.sh" --source-only

docker run                                        \
    -e ARM_ACCESS_KEY=$(storageAccountPrimaryKey) \
    -e ARM_CLIENT_ID=$servicePrincipalId          \
    -e ARM_CLIENT_SECRET=$servicePrincipalKey     \
    -e ARM_PROVIDER_STRICT                        \
    -e ARM_SUBSCRIPTION_ID                        \
    -e ARM_TENANT_ID=$(azureTenantId)             \
    -e TF_VAR_app_dev_subscription_id             \
    -e TF_VAR_ase_name                            \
    -e TF_VAR_ase_resource_group                  \
    -e TF_VAR_ase_subscription_id                 \
    -e TF_VAR_ase_vnet_name                       \
    -e TF_VAR_remote_state_account                \
    -e TF_VAR_remote_state_container              \
    -e TF_WARN_OUTPUT_ERRORS                      \
    --rm                                          \
    $(testHarnessBuildArtifactName)
