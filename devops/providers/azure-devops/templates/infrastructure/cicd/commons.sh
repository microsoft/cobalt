#!/usr/bin/env bash

set -euo pipefail

# A name unique to this build and pipeline
function testHarnessBuildArtifactName() {
    echo "$TEST_HARNESS_BUILD_ARTIFACT_IMAGE_PREFIX:$BUILD_SOURCEVERSION" 
}

# primary key for the storage account that will be used to track terraform state
function storageAccountPrimaryKey() {
    az storage account keys list --subscription "$AD_SP_SUBSCRIPTION_ID" --account-name "$REMOTE_STATE_ACCOUNT" --query "[0].value" --output tsv
}

function azureTenantId() {
    az account show --query "tenantId" --output tsv
}

function dockerLogin() {
    az acr login -n ${BASE_IMAGE_ACR_NAME}
}
