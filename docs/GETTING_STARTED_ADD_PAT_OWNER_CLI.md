# Getting Started - Advocated Pattern Owner - Azure CLI

*Prefer using portals? Follow the [portal-based walkthrough](./GETTING_STARTED_APP_PAT_OWNER.md).*

## Overview

Completion of the steps from this document results in an Azure Devops Repo initialized with carefully selected Cobalt Advocated Pattern Templates (Infrastructure as code) along with a CI/CD pipeline ready for multi-stage deployments.

This section provides Cobalt users instructions for initializing and integrating Cobalt into their existing AzureDevops organization using an Azure subscription. These steps assume some basic familiarity with the Azure DevOps portal, the Azure Cloud portal for validation and a desire to automate the creation of infrastructure. For more information on Cobalt, visit the following link: [READ ME](../README.md)

## Prerequisites

  * An Azure Subscription
  * Azure Devops Organization
  * Permissions to your Organization's Azure Devops account
  * *Global administrator role* permissions in your Organization's Azure Active Directory tenant to setup service principals
    * If this is not allowed by your organization, step two and the Service Connection creation in step three will need to be completed by someone within your organization with this permission.
  * Azure CLI
    * [Get started with Azure CLI](https://docs.microsoft.com/en-us/cli/azure/get-started-with-azure-cli?view=azure-cli-latest)
  * Azure DevOps CLI extension
    * [Get started with Azure DevOps CLI](https://docs.microsoft.com/en-us/azure/devops/cli/get-started?view=azure-devops)

## Steps

### 1. Setup Environment Variables

Define variables for ease of execution of snippets below.

| Variable | Sample Value | Description |
|----------|--------------|-------------|
| `TEMPLATE_DEVOPS_PROJECT_NAME` | `My Application` | The name of the project representing your Cobalt template application that serves as your organization's advocated pattern for a specific template. |
| `TEMPLATE_DEVOPS_INFRA_REPO_NAME` | `az-hello-world` | The name of the repo that will be created in the application Azure DevOps project to host the Cobalt template. |
| `TEMPLATE_DEVOPS_INFRA_YML_PATH` | `devops/providers/azure-devops/templates/azure-pipelines.yml` | The path relative to the `TEMPLATE_DEVOPS_INFRA_REPO_NAME` root that contains the Cobalt template pipeline to be created for testing and provisioning resources. |
| `DEFAULT_ORGANIZATION` | `https://dev.azure.com/MyOrganization/` | The full URL path of the organization in which your `TEMPLATE_DEVOPS_PROJECT_NAME` resides or will be created. |
| `COBALT_SOURCE_URL` | `https://github.com/microsoft/cobalt.git` | The Git clone URL for Cobalt (containing all templates including the one to be targeted by this template repository) from which this Cobalt template repository will be sourced. |

Update these values for your environment and application based on the guidance in the table above.

```bash
export TEMPLATE_DEVOPS_PROJECT_NAME=""
export TEMPLATE_DEVOPS_INFRA_REPO_NAME=""
export TEMPLATE_DEVOPS_INFRA_YML_PATH=""
export DEFAULT_ORGANIZATION=""
export COBALT_SOURCE_URL=""
export SUBSCRIPTION_ID=""
export SUBSCRIPTION_NAME=""
export TENANT_ID=""
export SERVICE_PRIN_ID=""
export SERVICE_CONN_NAME=""
export AGENT_POOL_NAME=""
```

The following values are used like constants and should not need to change (unless the build pipeline yaml definition is modified).

```bash
export COBALT_VAR_GROUP_INFRA="Infrastructure Pipeline Variables"
export COBALT_VAR_GROUP_ENV_SUFFIX="Environment Variables"
export COBALT_PIPELINE_NAME="Cobalt CICD Pipeline"
```

> NOTE: Before you can run Azure DevOps CLI commands, you need to run the login command (`az login` if using AAD/MSA identity else `az devops login` if using PAT token) to setup credentials. Please see https://aka.ms/azure-devops-cli-auth for more information.

### 2. Setup Azure

**Initialize Azure Repo Subscription with Cobalt**
* Create a new project

    
```bash
az devops configure --defaults organization="$DEFAULT_ORGANIZATION"
az devops project create --name "$TEMPLATE_DEVOPS_PROJECT_NAME" --source-control git --visibility private
az devops configure -d project="$TEMPLATE_DEVOPS_PROJECT_NAME"
```

* Create new repository by fetching source code from the master branch of Cobalt's open-source github project

    | Naming Recommendation  | Template Repo Strategy |
    |-------------|-----------|
    | Cobalt-Hello-World-Contoso | If the aim is to introduce oneself or the organization to Cobalt, we recommended a name that reflects the spirit of the Azure Hello World Cobalt template. |
    | Cobalt-AZ-ISO-Contoso | If the aim is to have a single repository represent a single Cobalt template, and thereafter, to have one repo per template, we recommend a name that reflects the Cobalt Template being deployed. In this naming example, the name assumes this repo will be dedicated to deploying the Cobalt *az-isolated-service-single-region* template |
    | Cobalt-Contoso | If the aim is to use a single repository as ground truth for all potential patterns across your organization, effectively having to manage a combination of Cobalt patterns from a single repo, it's recommended to stick with a name that matches the project name. |

```bash
az repos create --name "$TEMPLATE_DEVOPS_INFRA_REPO_NAME"
az repos import create --git-url $COBALT_SOURCE_URL --repository "$TEMPLATE_DEVOPS_INFRA_REPO_NAME"
```

* Initialize new Azure Devops pipeline

    ```
    az pipelines create --name "$COBALT_PIPELINE_NAME" --repository "$TEMPLATE_DEVOPS_INFRA_REPO_NAME" --branch master --repository-type tfsgit --yml-path $TEMPLATE_DEVOPS_INFRA_YML_PATH --skip-run true
    ```

2. **Provision Azure resources needed for Azure Devops pipeline**

    This step sets up all the values and resources that will serve as inputs to your test automation pipeline in Azure Devops. Without this setup step, you cannot deploy Cobalt templates to Azure Devops.

    * Create a registered Azure AD (AAD) app for Cobalt deployments
        * Sign-in to your organization's Azure account. (https://portal.azure.com)
        * Filter for Azure Active Directory and navigate to it's menu
        * Select App registrations from the menu blade
        * Click [Add/+] New registration then enter a name for the application (ex. cobalt-hw-admin-sp-`<username>` or cobalt-az-iso-admin-sp-`<username>`)
        * Choose single tenant as a supported account type
        * Click Register

    * Setup permissions for the new AAD app to also use legacy API permissions
        * From the App registrations service blade, select the API permissions
        * Click [+ Add a permission] then use the *APIs my Organization uses* tab to search for Windows Azure Active Directory
        * Configure Azure Activity Directory Application permissions to ReadWrite.OwnedBy

            ![Request Permissions menu](https://user-images.githubusercontent.com/10041279/63549279-b6896500-c4f5-11e9-9c92-40ac2a4295c9.png)

        * Click [Add permissions] to save this configuration
        * Click [Grant admin consent for *Your Directory*] to grant consent on behalf of users in this directory for this permission

    * Configure the new AAD app as a Cobalt admin service-principal/service-endpoint
        * From the App registrations service blade, click the [Certificates & secrets] tab
        * Click [+New client secret] from within the Client secrets menu then enter a description (ex. rbac)

            ![Client Secret menu](https://user-images.githubusercontent.com/10041279/63461963-69d35a80-c41f-11e9-8d4a-c72235177fb3.png)

        * Click Add
            > IMPORTANT: Generate a secret that does not have a trailing slash. Secrets that lead with a slash (ex."/","\") may cause parsing errors.

            > NOTE: Take note of the generated client secret (only displayed once). This will be used for your Azure Devops Service Connection in step 3.
        * From the App registrations service blade, select Overview.
            > NOTE: Take note of the Application (client) ID. This will also be used for your Azure Devops Service Connection in step 3.

    * Grant newly created Service Principal an Owner role to your preferred enterprise subscription.

        This elevates the Service Principal with more permissions so that Terraform can rely on this Service Principal as an Azure user for Cobalt template deployments.

        * Filter for subscriptions and navigate to the subscriptions list
        * Either choose a subscription or create a new one (ex. Cobalt-Contoso-Deployments)
        * Select your chosen subscription then select the Access control (IAM) tab from the menu blade.
        * Click [+/Add] and select Add role assignment
            * From the sub-menu, select 'Owner' as a role from the drop down and search for the newly created Service Principal (i.e. cobalt-hw-admin-sp-`<username>` or cobalt-az-iso-admin-sp-`<username>`)

                ![Role Assignment menu](https://user-images.githubusercontent.com/31149154/63708249-7ed23400-c7f9-11e9-8dbb-c15dcdaf3a37.png)

            * Click Save

    * Create Resource Group and Storage Account for backend state
        * Filter for Storage accounts and navigate to the storage account list
        * Click [+/Add] and enter values for the following fields:
            * Subscription: Your preferred enterprise subscription for Cobalt template deployments
            * Resource group: Create new (ex. cobalt-devint-hw-admin-rg or cobalt-devint-az-iso-admin-rg )
            * Storage account name: (ex. cobalttfstates)
        * Click [Review+Create] then [Create]
        * Once deployment for storage account is completed, go to the resource and visit the Blobs sub-menu
        * Click [+Container] then create a container name (ex. az-hw-remote-state-container or az-iso-remote-state-container) with private access


**Configure Azure Devops pipeline using Azure resource values**

***  Add the Azure Subscription being used for Cobalt as a *Service Connection*
The Service Connection Name should make sense to users and will be directly referenced in pipeline variable groups later.

> NOTE: Take note of the custom name given to this service connection. This will be referenced in later steps needed to configure env variable groups.

```bash
az devops service-endpoint azurerm create --azure-rm-subscription-id $SUBSCRIPTION_ID --azure-rm-subscription-name "$SUBSCRIPTION_NAME" --azure-rm-tenant-id $TENANT_ID --azure-rm-service-principal-id $SERVICE_PRIN_ID --name "$SERVICE_CONN_NAME"
```
* Configure variable groups 
* Configure *Infrastructure Pipeline Variables* as the first of two variable groups

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
            | Name   | Value | Var Description |
            |-------------|-----------|-----------|
            | `AGENT_POOL` | Hosted Ubuntu 1604 | The type of build agent used for your deployment. |
            | `ARM_PROVIDER_STRICT` | true | Terraform ARM provider modification |
            | `BUILD_ARTIFACT_NAME` | drop | Name to identity the folder containing artifacts output by a build. |
            | `GO_VERSION`| 1.12.5 | The version of Go terraform deployments are bound to. |
            | `PIPELINE_ROOT_DIR` | devops/providers/azure-devops/templates/ | A path for finding Cobalt templates. |
            | `REMOTE_STATE_CONTAINER` | `<BACKEND_STATE_CONTAINER_NAME>`| The remote blob storage container name for managing the state of a Cobalt Template's deployed infrastructure. Also is used as a naming convention for partitioning state into multiple workspaces. This name was created in an earlier step from within the azure portal. |
            | `SCRIPTS_DIR` | infrastructure/scripts | Path to scripts used at runtime for composing build and release jobs at various pipeline stages. |
            | `TEST_HARNESS_DIR` | test-harness/ | A path to the cobalt test harness for running integration and unit tests written in Docker and Golang. |
            | `TF_ROOT_DIR`| infra | The primary path for all Cobalt templates and the modules they are composed of. |
            | `TF_VERSION`| 0.12.4 | The version of terraform deployments are bound to. |
            | `TF_WARN_OUTPUT_ERRORS`| 1 | The severity level of errors to report. |

    > Important: Every targeted environment specified within the build pipeline expects a
    > variable group specified with the naming convention `<ENVIRONMENT_NAME> Environment Variables`

* Configure *DevInt Environment Variables* as the final variable group

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



```bash
az pipelines show --name "$COBALT_PIPELINE_NAME" -o json > builddef.json
PIPELINE_ID=$(az pipelines show --name "$COBALT_PIPELINE_NAME" --query id)
```

Execute the list command to find the Variable Group IDs created earlier. Make note of the IDs as they will need to be added to the build pipeline definition.

```bash
az pipelines variable-group list
```

For the workaround, you'll be manually editing the builddef.json file to add the variable group references. At the end of the file, you should see the line `"variableGroups" : null`. Replace the value with the following, replacing the variable group ID placeholders (`0`) with those from the above command for the Infrastructure Pipeline Variables group and DevInt Environment Variables group:
```bash
"variableGroups": [
    { "id": 0 },
    { "id": 0 }
],
```

```bash
az devops invoke --http-method PUT --area build --resource definitions --route-parameters project="$TEMPLATE_DEVOPS_PROJECT_NAME" definitionId=$PIPELINE_ID --in-file builddef.json

```

**Clone newly created Azure DevOps Repo from your organization**


```bash
$ git clone <insert-git-repo-url>
```

5. **Keep the templates relevant to your enterprise patterns**

    The goal of this step is to continue efforts removing infrastructure as code Cobalt templates that users have no interest in deploying.

    * Open the project from your favorite IDE and navigate to infrastructure templates `./infra/templates` directory.
    * Manually delete template directories not needed for your enterprise.
    * The CI/CD pipeline needs to detect a code change to run tests. Add a comment or extra line to a TF or Go file in order to force tests to run.
    > NOTE: Do not delete 'backend-state-setup' template! We also recommended keeping the 'az-hello-world' template as a starter template.
    * Commit the newly pruned project to your newly forked repo.
        ```bash
        $ git commit -m "Removed unrelated templates." && git push
        ```
    > NOTE: Integration tests running in the release stage of the pipeline may have resource group level naming conflicts if other tests of the same templates are also running or have been persisted in the Azure portal.

```bash
az pipelines run --name "$COBALT_PIPELINE_NAME"
```

## Additional Recommendations

 Recommended next step is to either reference containerized applications by their image name from within a Cobalt template in order to run a deployment or to employ this repo as ground truth for acceptable patterns and versioning across an organization.
