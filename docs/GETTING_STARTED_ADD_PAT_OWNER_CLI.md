# Getting Started - Advocated Pattern Owner - Azure CLI

*Prefer using portals? Follow the [portal-based walkthrough](./GETTING_STARTED_ADD_PAT_OWNER.md).*

[Markdown Link](./GETTING_STARTED_ADD_PAT_OWNER.md###Steps)

## Overview

Completion of the steps from this document results in an Azure Devops Repo initialized with carefully selected Cobalt Advocated Pattern Templates (Infrastructure as code) along with a CI/CD pipeline ready for multi-stage deployments.

This section provides Cobalt users instructions for initializing and integrating Cobalt into their existing AzureDevops organization using an Azure subscription. These steps assume some basic familiarity with the Azure Devops portal, the Azure Cloud portal for validation and a desire to automate the creation of infrastructure. For more information on Cobalt, visit the following link: [READ ME](../README.md)

## Prerequisites

  * An Azure Subscription
  * Azure Devops Organization
  * Permissions to your Organization's Azure Devops account
  * *Global administrator role* permissions in your Organization's Azure Active Directory tenant to setup service principals
    * If this is not allowed by your organization, these steps will need to be completed by someone within your organization with elevated permissions.
  * Azure CLI
    * [Get started with Azure CLI](https://docs.microsoft.com/en-us/cli/azure/get-started-with-azure-cli?view=azure-cli-latest)
  * Azure Devops CLI extension
    * [Get started with Azure Devops CLI](https://docs.microsoft.com/en-us/azure/devops/cli/get-started?view=azure-devops)

## Steps

### 1. Setup Environment Variables

The environment variables set below will be referenced by various cli commands highlighted throughout this install script.

| Variable | Sample Value | Description |
|----------|--------------|-------------|
| `TEMPLATE_DEVOPS_PROJECT_NAME` | `My Application` | The name of the project representing your Cobalt template application that serves as your organization's advocated pattern for a specific template. |
| `TEMPLATE_DEVOPS_INFRA_REPO_NAME` | `az-hello-world` | The name of the repo that will be created in the application Azure Devops project to host the Cobalt template. |
| `TEMPLATE_DEVOPS_INFRA_YML_PATH` | `devops/providers/azure-devops/templates/azure-pipelines.yml` | The path relative to the `TEMPLATE_DEVOPS_INFRA_REPO_NAME` root that contains the Cobalt template pipeline to be created for testing and provisioning resources. |
| `DEFAULT_ORGANIZATION` | `https://dev.azure.com/MyOrganization/` | The full URL path of the organization in which your `TEMPLATE_DEVOPS_PROJECT_NAME` resides or will be created. |
| `COBALT_SOURCE_URL` | `https://github.com/microsoft/cobalt.git` | The Git clone URL for Cobalt (containing all templates including the one to be targeted by this template repository) from which this Cobalt template repository will be sourced. |

#### a. Update these values for your environment and application based on the guidance in the table above

```bash
export TEMPLATE_DEVOPS_PROJECT_NAME=""
export TEMPLATE_DEVOPS_INFRA_REPO_NAME=""
export TEMPLATE_DEVOPS_INFRA_YML_PATH=""
export DEFAULT_ORGANIZATION=""
export COBALT_SOURCE_URL=""
export SUBSCRIPTION_ID=""
export SUBSCRIPTION_NAME=""
export TENANT_ID=""
export AGENT_POOL_NAME=""
```

| Naming Recommendation for <TEMPLATE_DEVOPS_INFRA_REPO_NAME> | Template Repo Strategy |
|-------------|-----------|
| Cobalt-Hello-World-Contoso | If the aim is to introduce oneself or the organization to Cobalt, we recommended a name that reflects the spirit of the Azure Hello World Cobalt template. |
| Cobalt-AZ-ISO-Contoso | If the aim is to have a single repository represent a single Cobalt template, and thereafter, to have one repo per template, we recommend a name that reflects the Cobalt Template being deployed. In this naming example, the name assumes this repo will be dedicated to deploying the Cobalt *az-isolated-service-single-region* template |
| Cobalt-Contoso | If the aim is to use a single repository as ground truth for all potential patterns across your organization, effectively having to manage a combination of Cobalt patterns from a single repo, it's recommended to stick with a name that matches the project name. |

The following values are used like constants and should not need to change (unless the build pipeline yaml definition is modified).

```bash
export COBALT_VAR_GROUP_INFRA="Infrastructure Pipeline Variables"
export COBALT_VAR_GROUP_ENV_SUFFIX="Environment Variables"
export COBALT_PIPELINE_NAME="Cobalt CICD Pipeline"
```

### 2. Create and Configure Azure Devops Project

The following steps help setup your Azure Devops repo with Cobalt Advocated Pattern Templates that matter to you. These are common cli instructions that are needed for any audience interested in using Cobalt for infrastructure automation.

> NOTE: Before you can run Azure Devops CLI commands, you need to run the login command (`az login` if using AAD/MSA identity else `az devops login` if using PAT token) to setup credentials. Please see https://aka.ms/azure-devops-cli-auth for more information.

#### a. Run the following commands to create a new project for an Azure Devops Organization

The below will create a project and set your organization as the default organization for all subsequent Azure Devops CLI commands.

```bash
az devops configure --defaults organization="$DEFAULT_ORGANIZATION"
az devops project create --name "$TEMPLATE_DEVOPS_PROJECT_NAME" --source-control git --visibility private
az devops configure -d project="$TEMPLATE_DEVOPS_PROJECT_NAME"
```

#### b. Run the following commands to fork Cobalt's master repo into your Azure Devops Project

```bash
az repos create --name "$TEMPLATE_DEVOPS_INFRA_REPO_NAME"
az repos import create --git-url $COBALT_SOURCE_URL --repository "$TEMPLATE_DEVOPS_INFRA_REPO_NAME"
```

### 3. Provision Azure resources needed for Azure Devops CI/CD Build Pipeline

These step sets up all the values and resources that will serve as inputs to your test automation pipeline in Azure Devops. Without this setup step, you cannot deploy Cobalt Templates to Azure Devops.

*Steps for provisioning the Azure resources can be found using the [portal-based walkthrough steps](./GETTING_STARTED_ADD_PAT_OWNER.md#steps).*

### 4. Setup Azure Devops CI/CD Build Pipeline for Cobalt using Azure resources

Resource groups, Service Principal and Storage Accounts created in Azure will now need to be used for setting up your Azure Devops CI/CD build pipeline.

#### a. Run the following commands to create a new Azure Devops CI/CD build pipeline

We are intentionally skipping the initial run since we know it will fail; we need to link the required variables groups to this pipeline, and that will be done later.

```bash
az pipelines create --name "$COBALT_PIPELINE_NAME" --repository "$TEMPLATE_DEVOPS_INFRA_REPO_NAME" --branch master --repository-type tfsgit --yml-path $TEMPLATE_DEVOPS_INFRA_YML_PATH --skip-run true
```

#### b. Add the Azure Principle being used for Cobalt as a *Service Connection*

> NOTE: The custom name chosen for the Service Connection will be referenced in later steps needed to configure env variable groups.

```bash
export SERVICE_PRIN_ID=""
export SERVICE_CONN_NAME=""
```

```bash
az devops service-endpoint azurerm create --azure-rm-subscription-id $SUBSCRIPTION_ID --azure-rm-subscription-name "$SUBSCRIPTION_NAME" --azure-rm-tenant-id $TENANT_ID --azure-rm-service-principal-id $SERVICE_PRIN_ID --name "$SERVICE_CONN_NAME"
```

#### c. Configure "*Infrastructure Pipeline Variables*" as the first of two variable groups

Variable groups are utilized by the pipeline to configure how the Cobalt template will be tested and deployed. The `az pipelines variable-group create` `--variables` flag expects a list of space-delimited key value pairs (e.g., `KEY1='val1' KEY2=true`).

```bash
# IMPORTANT: Replace these values as necessary to fit your environment.
az pipelines variable-group create --authorize true --name "$COBALT_VAR_GROUP_INFRA" --variables \
    AGENT_POOL="$AGENT_POOL_NAME" \
    ARM_PROVIDER_STRICT=true \
    BUILD_ARTIFACT_NAME='drop' \
    BUILD_ARTIFACT_PATH_ALIAS='artifact' \
    GO_VERSION='1.12.5' \
    PIPELINE_ROOT_DIR='devops/providers/azure-devops/templates/infrastructure' \
    REMOTE_STATE_CONTAINER='BACKENDSTATECONTAINERNAME' \
    SCRIPTS_DIR='scripts' \
    TEST_HARNESS_DIR='test-harness/' \
    TF_DEPLOYMENT_TEMPLATE_ROOT='infra/templates/$TEMPLATE_DEVOPS_INFRA_REPO_NAME' \
    TF_DEPLOYMENT_WORKSPACE_PREFIX='PROJECTDEPLOYMENTWORKSPACEPREFIX' \
    TF_ROOT_DIR='infra' \
    TF_VERSION='0.12.4' \
    TF_WARN_OUTPUT_ERRORS=1
```

> NOTE: Every targeted environment specified within the build pipeline expects a variable group specified with the naming convention "`<ENVIRONMENT_NAME> Environment Variables`"

> OPTIONAL: Cobalt deployments can be configured to run a single template by setting them as root directory templates and silencing others. Simply make the following variable point to the desired template: ex. "`TF_DEPLOYMENT_TEMPLATE_ROOT=infra/templates/az-isolated-service-single-region`"

| Name   | Value | Var Description |
|-------------|-----------|-----------|
| `AGENT_POOL` | Hosted Ubuntu 1604 | The type of build agent used for your deployment. |
| `ARM_PROVIDER_STRICT` | true | Terraform ARM provider modification |
| `BUILD_ARTIFACT_NAME` | drop | Name to identity the folder containing artifacts output by a build. |
| `GO_VERSION`| 1.12.5 | The version of Go terraform deployments are bound to. |
| `PIPELINE_ROOT_DIR` | devops/providers/azure-devops/templates/ | A path for finding Cobalt Templates. |
| `REMOTE_STATE_CONTAINER` | `<BACKEND_STATE_CONTAINER_NAME>`| The remote blob storage container name for managing the state of a Cobalt Template's deployed infrastructure. Also is used as a naming convention for partitioning state into multiple workspaces. This name was created in an earlier step from within the azure portal. |
| `SCRIPTS_DIR` | infrastructure/scripts | Path to scripts used at runtime for composing build and release jobs at various pipeline stages. |
| `TEST_HARNESS_DIR` | test-harness/ | A path to the cobalt test harness for running integration and unit tests written in Docker and Golang. |
| `TF_ROOT_DIR`| infra | The primary path for all Cobalt Templates and the modules they are composed of. |
| `TF_VERSION`| 0.12.4 | The version of terraform deployments are bound to. |
| `TF_WARN_OUTPUT_ERRORS`| 1 | The severity level of errors to report. |

#### d. Configure "*DevInt Environment Variables*" as the final variable group

```bash
# IMPORTANT: Replace these values as necessary to fit your environment.
DEVINT_VAR_GROUP="DevInt $COBALT_VAR_GROUP_ENV_SUFFIX"
az pipelines variable-group create --authorize true --name "$DEVINT_VAR_GROUP" --variables \
    ARM_SUBSCRIPTION_ID='TARGETSUBSCRIPTIONID' \
    REMOTE_STATE_ACCOUNT='BACKENDSTATESTORAGEACCOUNTNAME' \
    SERVICE_CONNECTION_NAME='SERVICECONNECTIONNAME'
```

| Name  | Value | Var Description |
|-------------|-----------|-----------|
| `ARM_SUBSCRIPTION_ID` | `<ARM_SUBSCRIPTION_ID>` | The Azure subscription ID for which all resources will be deployed. Refer to the Azure subscription chosen in Azure portal for Cobalt deployments. |
| `REMOTE_STATE_ACCOUNT` | `<AZURE_STORAGE_ACCOUNT_NAME>` | The storage container account name created in a previous step that is used to manage the state of this deployment pipeline. The storage Account is shared among all non-prod deployment stages. |
| `SERVICE_CONNECTION_NAME` | ex. Cobalt Deployment Administrator-`<TenantName>` | The custom name of the service connection configured in a previous Azure Devops step that establishes a connection between the Service Principal and the Azure subscription that it's permissioned for. |

#### e. Link the variable groups to the build pipeline

> NOTE: At this time, the Azure Devops CLI does not support linking variable groups to pipelines. We have a temporary workaround utilizing the Azure Devops `invoke` command to directly call the Azure Devops REST API to update the build definition.

Write the current value of the build pipeline definition to a temporary local file, and save the PIPELINE_ID.

```bash
az pipelines show --name "$COBALT_PIPELINE_NAME" -o json > builddef.json
PIPELINE_ID=$(az pipelines show --name "$COBALT_PIPELINE_NAME" --query id)
```

Execute the list command to find the Variable Group IDs created earlier. Make note of the IDs as they will need to be added to the build pipeline definition.

```bash
az pipelines variable-group list
```

Here, you'll be manually editing the builddef.json file to add the variable group references. At the end of the file, you should see the line `"variableGroups" : null`. Replace the value with the following, replacing the variable group ID placeholders (`0`) with those from the above command for the Infrastructure Pipeline Variables group and DevInt Environment Variables group:

```bash
"variableGroups": [
    { "id": 0 },
    { "id": 0 }
],
```

Save the file. Use the az devops invoke command to update the pipeline build definition with the linked variable groups.

```bash
az devops invoke --http-method PUT --area build --resource definitions --route-parameters project="$TEMPLATE_DEVOPS_PROJECT_NAME" definitionId=$PIPELINE_ID --in-file builddef.json
```

### 5. Keep the Cobalt Templates relevant to your enterprise patterns and run the pipeline

The goal of this step is to remove infrastructure as code Cobalt Templates that owners of the project have no interest in deploying.

#### a. Clone newly created Azure Devops Repo from your organization

Clone the project into a local repo directory

```bash
git clone <insert-git-repo-url>
```

#### b. Review devops pipeline YAML

Remove jobName configurations not relevant to your enterprise patterns. If new to Cobalt, we recommend keeping the path to the az_hello_world template as a starter template. Below is an example of a jobName that you may want to remove by simple deleting the section from the file.

```yaml
configurationMatrix:
- jobName: az_service_single_region
terraformTemplatePath: 'infra/templates/az-service-single-region'
terraformWorkspacePrefix: 'sr'
environmentsToTeardownAfterRelease:
- 'devint'
```

#### c. Review Cobalt Templates

Manually delete template directories not needed for your enterprise. These will most likely reflect the same templates removed from the devops pipeline YAML. (Do not delete 'backend-state-setup' template! We also recommended keeping the 'az-hello-world' Cobalt Template as a starter template.)

![image](https://user-images.githubusercontent.com/10041279/64913136-1d1e2f00-d700-11e9-95cd-9e95c257bcbd.png)

> NOTE: The CI/CD pipeline needs to detect a code change to run the template-specific build and release jobs (in their respective stages). To force the template build and release to run, you may add a `FORCE_RUN` environment variable with a value of `true` to your *Devint Environment Variables* variable group. You may also add a comment or extra line to a TF or Go file within the template in order for the pipeline script to detect a change without adding any additional override flags

#### b. Commit, Run and verify

```bash
git commit -m "Removed unrelated templates." && git push
az pipelines run --name "$COBALT_PIPELINE_NAME"
```

> NOTE: Integration tests running in the release stage of the pipeline may have resource group level naming conflicts if other tests of the same templates are also running or have been persisted in the Azure portal.

## Additional Recommendations

Recommended next step is to either reference containerized applications by their image name from within a Cobalt Template in order to run a deployment or to employ this repo as ground truth for acceptable patterns and versioning across an organization.
