#!/usr/bin/env bash

set -euo pipefail

# A name unique to this build and pipeline
function testHarnessBuildArtifactName() {
    echo "$TEST_HARNESS_BUILD_ARTIFACT_IMAGE_PREFIX:$BUILD_SOURCEVERSION" 
}

# primary key for the storage account that will be used to track terraform state
function storageAccountPrimaryKey() {
    az storage account keys list --subscription "$ARM_SUBSCRIPTION_ID" --account-name "$TF_VAR_remote_state_account" --query "[0].value" --output tsv
}

function azureTenantId() {
    az account show --query "tenantId" --output tsv
}

function dockerLogin() {
    az acr login -n ${BASE_IMAGE_ACR_NAME}
}

function terraformVersionCheck() {
    if [[ $(which terraform) && $(terraform --version | head -n1 | cut -d" " -f2 | cut -c 2\-) == $TF_VERSION ]]; then
        echo "Terraform version check completed"
      else
        TF_ZIP_TARGET="https://releases.hashicorp.com/terraform/$TF_VERSION/terraform_${TF_VERSION}_linux_amd64.zip"
        echo "Info: installing $TF_VERSION, target: $TF_ZIP_TARGET"
 
        wget $TF_ZIP_TARGET -q
        unzip -q "terraform_${TF_VERSION}_linux_amd64.zip"
        sudo mv terraform /usr/local/bin
        rm *.zip
    fi
    
    terraform -version

    # Assert that jq is available, and install if it's not
    command -v jq >/dev/null 2>&1 || { echo >&2 "Installing jq"; sudo apt install -y jq; }
}
