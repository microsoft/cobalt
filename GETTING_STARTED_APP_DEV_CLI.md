# Getting Started - Application Developer - Azure CLI

## Overview

This section provides application developers wishing to host solutions on Cobalt templates recommendations for building their infrastructure-as-code repository and accompanying CI/CD pipelines. It assumes an isolated Azure DevOps Project with a Cobalt template Repo and Build Pipeline has already been created as defined in the [Getting Started - Advocated Pattern Owner](./GETTING_STARTED_ADD_PAT_OWNER.md) walkthrough.

By creating an application-specific project, you are creating a single project supporting the two main pillars of an application -- the Cobalt-template-based infrastructure and CI/CD build pipeline, and the application code and CI/CD build pipeline. **Important**: as an application developer, you will not be modifying the Cobalt template even though you will be importing all of the required code into your project repository. Instead, you will be responsible only for modifying the configuration via the template's `terraform.tfvars` file to support your application's unique settings (e.g., the number of deployment targets to create or Azure Container Registry image URLs). 

There may be many applications forking from a single governed organization-specific Cobalt template, and requested changes should be made to the source Cobalt template repository so that all applications may update to the latest when needed.

## Prerequisites

* Azure CLI
  * [Get started with Azure CLI](https://docs.microsoft.com/en-us/cli/azure/get-started-with-azure-cli?view=azure-cli-latest)
* Azure DevOps CLI extension
  * [Get started with Azure DevOps CLI](https://docs.microsoft.com/en-us/azure/devops/cli/get-started?view=azure-devops)
* Existing repository and CI/CD pipeline for desired Cobalt template 
  * [Getting Started - Advocated Pattern Owner](./GETTING_STARTED_ADD_PAT_OWNER.md)

## Steps

```bash
#
# 1. Setup Environment Variables
#

# Define variables shared across commands representing the project to be 
# created or used, the name of the repository to be created to host Cobalt
# source in the application project, and the path within the Cobalt source
# to the build pipeline definition. Make sure to replace the values below
# in all caps to fit the context of where your organizational Cobalt
# source template repo is hosted and your application project name.
export APP_DEVOPS_PROJECT_NAME="APP PROJECT NAME"
export APP_DEVOPS_INFRA_REPO_NAME="infrastructure"
export APP_DEVOPS_INFRA_YML_PATH="devops/providers/azure-devops/templates/azure-pipelines.yml"
export DEFAULT_ORGANIZATION="https://dev.azure.com/ORGANIZATIONNAME/"
export GIT_SOURCE_URL="https://dev.azure.com/COBALTSOURCEPROJECT/_git/COBALTSOURCEPROJECTREPO"

# These values are used like constants and should not change (unless the
# build pipeline definition is modified).
export COBALT_VAR_GROUP_INFRA="Infrastructure Pipeline Variables"
export COBALT_VAR_GROUP_ENV_SUFFIX="Environment Variables"
export COBALT_PIPELINE_NAME="Cobalt CICD Pipeline"

# NOTE: Before you can run Azure DevOps commands, you need to run the login
# command(az login if using AAD/MSA identity else az devops login if using
# PAT token) to setup credentials.
# Please see https://aka.ms/azure-devops-cli-auth for more information.

#
# 2. Setup Azure DevOps Project
#

# Set your organization as the default organization for all susequent commands
az devops configure -d organization=$DEFAULT_ORGANIZATION

# (OPTIONAL) Create the project if your project does not already exist
az devops project create --name $APP_DEVOPS_PROJECT_NAME

# Set the project as the default project for all subsequent commands
az devops configure -d project=$APP_DEVOPS_PROJECT_NAME

#
# 3. Setup Azure DevOps Repo for Cobalt source
#

# Create a new repo for Cobalt source
az repos create --name $APP_DEVOPS_INFRA_REPO_NAME

# Import the Cobalt source
az repos import create --git-url $GIT_SOURCE_URL --repository $APP_DEVOPS_INFRA_REPO_NAME
# NOTE: This command only works with public Git repositories. If the source
# repository is private, you can manually import the source repository. This
# operation requires a temporary local clone of the private repository.
#
# IMPORTANT: This approach would require a Personal Access Token with permissions
# to clone / read the private source repo, and a Personal Access Token with
# permissions to write / push to the new private source repo as we're using
# native git commands.
#
# # Set the (new) target repository URL
# GIT_TARGET_URL=$(az repos show -r $APP_DEVOPS_INFRA_REPO_NAME --query webUrl)
#
# mkdir temprepo
# cd temprepo
# 
# # Clone the private repo to a temp local directory
# git clone --bare $GIT_SOURCE_URL .
#
# # Copy the source repo to the target repo
# git push --mirror $GIT_TARGET_URL
#
# # (Optional) If the source repo has LFS objects, fetch and copy to target repo
# git lfs fetch origin --all
# git lfs push --all $GIT_TARGET_URL
# 
# # Delete temporary folder with local clone
# cd ..
# rm -rf temprepo

# Edit the pipeline definition to only setup only the az-hello-world-template.
# Commit the updated pipeline definition.

#
# 4. Setup Azure DevOps CI/CD Build Pipeline for Cobalt
#

# Create the build pipeline. We are intentionally skipping the initial run
# since we know it will fail; we need to link the required variables groups
# to this pipeline, and currently that cannot be done directly through the
# Azure DevOps CLI.
az pipelines create --name $COBALT_PIPELINE_NAME --repository $APP_DEVOPS_INFRA_REPO_NAME --branch master --repository-type tfsgit --yml-path $APP_DEVOPS_INFRA_YML_PATH --skip-run true

# Variable groups are utilized by the pipeline to configure how the Cobalt
# template will be tested and deployed. Within the pipeline build definition
# you may specify the number of environments that will be targed for
# deployment. For each environment specified, you will need a variable
# group that defines the Azure Subscription ID to where the infrastructure
# will be provisioned. You will also need to set a Service Connection that
# has permissions to provision resources on that subscription.

# The az pipelines variable-group create --variables flag expects a list of
# space-delimited key value pairs (e.g., KEY1='val1' KEY2=true).

# Globally-utilized Infrastructure Pipeline Variables. IMPORTANT: Replace
# these values as necessary to fit your environment.
az pipelines variable-group create --authorize true --name $COBALT_VAR_GROUP_INFRA --variables \
    AGENT_POOL='Hosted Ubuntu 1604' \
    ARM_PROVIDER_STRICT=true \
    BUILD_ARTIFACT_NAME='drop' \
    BUILD_ARTIFACT_PATH_ALIAS='artifact' \
    GO_VERSION='1.12.5' \
    PIPELINE_ROOT_DIR='devops/providers/azure-devops/templates/infrastructure' \
    REMOTE_STATE_CONTAINER='BACKENDSTATECONTAINERNAME' \
    SCRIPTS_DIR='scripts' \
    TEST_HARNESS_DIR='test-harness/' \
    TF_DEPLOYMENT_TEMPLATE_ROOT='infra/templates/az-hello-world' \
    TF_DEPLOYMENT_WORKSPACE_PREFIX='PROJECTDEPLOYMENTWORKSPACEPREFIX' \
    TF_ROOT_DIR='infra' \
    TF_VERSION='0.12.4' \
    TF_WARN_OUTPUT_ERRORS=1

# Build-specified Environment Variables. (Only creating a variable group
# for the DevInt environment with this command execute multiple times for
# every environment specified within the build pipeline definition). For
# this getting started, we will only be creating a DevInt environment. We
# also assume that we can reuse the Service Connection created as part of
# the organization Cobalt template source Getting Started walkthrough.
DEVINT_VAR_GROUP="DevInt $COBALT_VAR_GROUP_ENV_SUFFIX"
az pipelines variable-group create --authorize true --name $DEVINT_VAR_GROUP --variables \
    ARM_SUBSCRIPTION_ID='TARGETSUBSCRIPTIONID' \
    REMOTE_STATE_ACCOUNT='BACKENDSTATESTORAGEACCOUNTNAME' \
    SERVICE_CONNECTION_NAME='SERVICECONNECTIONNAME'

# At this time, the Azure DevOps CLI does not support linking variable
# groups to pipelines. We have a temporary workaround utilizing the Azure
# DevOps invoke command to directly call the Azure DevOps REST API to
# update the build definition.

# Write the current value of the build pipeline definition to a temporary local
# file, and save the PIPELINE_ID.
az pipelines show --name $COBALT_PIPELINE_NAME -o json > builddef.json
PIPELINE_ID=$(az pipelines show --name $COBALT_PIPELINE_NAME --query id)

# Execute the list command to find the Variable Group IDs. Make note of
# the IDs as they will need to be added to the build pipeline definition.
az pipelines variable-group list

# For the workaround, you'll be manually editing the builddef.json file
# to add the variable group references. At the end of the file, you should
# see the line "variableGroups" : null. Replace the null value with the
# following, replacing the variable group ID placeholders with those found 
# above:
  "variableGroups": [
      { "id": INFRAVARGROUP_ID },
      { "id": DEVINTVARGROUP_ID }
  ],

# Save the file. Use the az devops invoke command to update the pipeline
# build definition with the linked variable groups.
az devops invoke --http-method PUT --area build --resource definitions --route-parameters project=$APP_DEVOPS_PROJECT_NAME definitionId=$PIPELINE_ID --in-file builddef.json

#
# 5. Run and verify 
#

# Queue a pipeline to run
az pipelines run --name $COBALT_PIPELINE_NAME

# At this point, the pipeline definition tears down any infrastructure
# provisioned. Update the pipeline definition to remove the environment
# teardown, and it should remain provisioned and available for use by
# the application. 
```

## Outcomes

After completing these steps, you should have an Azure DevOps Project for your application that contains:
* An Azure DevOps Repo for your application's Cobalt template infrastructure
* An Azure DevOps Build CI/CD Pipeline for your application's Cobalt template infrastructure including successful deployment and provisioning of template resources
* Provisioned durable resources available in your target Azure Subscription

## Additional Recommendations

We recommend creating a separate repository in the same shared application project for your application code. Additionally, an application CI / CD build pipeline should be created to manage the application. The application project will then have two pillars -- one supporting the Cobalt template infrastructure configuration specific to the application, and one supporting the application development.
