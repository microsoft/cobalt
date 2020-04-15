# Getting Started - Advocated Pattern Owner

## Cobalt Enterprise Integration - Overview

Completion of the steps from this document results in an Azure Devops Repo initialized with carefully selected Cobalt Advocated Pattern Templates (Infrastructure as code) along with a CI/CD pipeline ready for multi-stage deployments.

This document provides Cobalt users instructions for initializing and integrating Cobalt into their existing AzureDevops organization using an Azure subscription. These steps assume some basic familiarity with the Azure DevOps portal and a desire to automate the creation of infrastructure. For more information on Cobalt, visit the following link: [READ ME](../README.md)

### Prerequisites

  * An Azure Subscription
  * Azure Devops Organization
  * Permissions to your Organization's Azure Devops account
  * *Global administrator role* permissions in your Organization's Azure Active Directory tenant to setup service principals
    * If this is not allowed by your organization, step two and the Service Connection creation in step three will need to be completed by someone within your organization with this permission.

> If using the CLI commands please set the following variables:

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

The following values are used like constants and should not need to change (unless the build pipeline definition is modified).

```bash
export COBALT_PIPELINE_NAME="Cobalt CICD Pipeline"
```

### STEPS

1. **Initialize Azure Repo Subscription with Cobalt**

    This step helps setup your Azure Devops repo with Cobalt Advocated Pattern Templates that matter to you. These are common instructions that are needed for any audience interested in using Cobalt for infrastructure automation.

    * Create a new project
        * Sign-in to Azure DevOps (https://azure.microsoft.com/en-us/services/devops/)
        * Select New project and create a name. (ex. Cobalt-Contoso)

            ![New Project](https://user-images.githubusercontent.com/10041279/63442791-4f868600-c3f9-11e9-91f3-c959654f5a1c.png)

        * Select Create

> The following CLI command(s) can be run as an alternative to using the portal-based instructions:

    
```bash
az devops configure --defaults organization="$DEFAULT_ORGANIZATION"
az devops project create --name "$TEMPLATE_DEVOPS_PROJECT_NAME" --source-control git --visibility private
az devops configure -d project="$TEMPLATE_DEVOPS_PROJECT_NAME"
```

* Create new repository by fetching source code from the master branch of Cobalt's open-source github project
    * Select Repos tab within side-navigation menu
    * Select 'Import a repository' from the Repos tab sub-menu and click [Import]
    * Enter the Cobalt Clone URL (https://github.com/microsoft/cobalt.git) and select Import

        ![Clone Button](https://user-images.githubusercontent.com/10041279/63459072-8ec4cf00-c419-11e9-8ef4-ee7db827e49c.png)

    * Rename your repository
        * Click your Repo Name (ex. Cobalt-Contoso) at the top of the page.

            ![Repo Name dropdown](https://user-images.githubusercontent.com/10041279/63615290-9d8ebb80-c5aa-11e9-9136-64295640205b.png)

        * Select Manage Repositories
        * Under Git repositories, find "Cobalt-Contoso" and select the ellipses
        * Select Rename repository

            ![Rename Repo dropdown](https://user-images.githubusercontent.com/10041279/63615540-3b828600-c5ab-11e9-9174-07f23b3193bf.png)

        * Give it a new name and click [Rename]

            | Naming Recommendation  | Template Repo Strategy |
            |-------------|-----------|
            | Cobalt-Hello-World-Contoso | If the aim is to introduce oneself or the organization to Cobalt, we recommended a name that reflects the spirit of the Azure Hello World Cobalt template. |
            | Cobalt-AZ-ISO-Contoso | If the aim is to have a single repository represent a single Cobalt template, and thereafter, to have one repo per template, we recommend a name that reflects the Cobalt Template being deployed. In this naming example, the name assumes this repo will be dedicated to deploying the Cobalt *az-isolated-service-single-region* template |
            | Cobalt-Contoso | If the aim is to use a single repository as ground truth for all potential patterns across your organization, effectively having to manage a combination of Cobalt patterns from a single repo, it's recommended to stick with a name that matches the project name. |


> The following CLI command(s) can be run as an alternative to using the portal-based instructions:

```bash
az repos create --name "$TEMPLATE_DEVOPS_INFRA_REPO_NAME"
az repos import create --git-url $COBALT_SOURCE_URL --repository "$TEMPLATE_DEVOPS_INFRA_REPO_NAME"
```

* Initialize new Azure Devops pipeline
    * Select Pipelines tab from within side-navigation menu
    * Select Create Pipeline and then choose 'Azure Repos Git [YAML]'

        ![Pipeline Menu](https://user-images.githubusercontent.com/10041279/63459652-89b44f80-c41a-11e9-829a-05a6888b7673.png)

    * Find and select the newly created repository from dropdown menu
    * Import YAML by selecting 'Existing Azure Pipelines YAML file'
        * Enter the path to the devops yaml file that lives within your newly created repo. (i.e. devops/providers/azure-devops/templates/azure-pipelines.yml)

        ![Select YAML](https://user-images.githubusercontent.com/10041279/63459938-21b23900-c41b-11e9-9b9c-2dfa72e51350.png)

        > NOTE: Automatic drop-down does not always populate with yaml file options. It may be necessary to simply copy and paste the above path.
    * Review devops pipeline YAML and only keep templates relevant to your enterprise patterns.
        * Remove jobName configurations not relevant to your enterprise patterns. If new to Cobalt, we recommend keeping the path to the az_hello_world template as a starter template. This step can also be completed later as a code commit to your repo. Below is an example of a jobName that you may want to remove by simple deleting it.
            ```yaml
            configurationMatrix:
            - jobName: az_service_single_region
            terraformTemplatePath: 'infra/templates/az-service-single-region'   # NOTE: this can be configured as an environment variable if needed!
            terraformWorkspacePrefix: 'sr'
            environmentsToTeardownAfterRelease:
            - 'devint'
            ```
    * Save and run

        ![Fail Screenshot](https://user-images.githubusercontent.com/10041279/63546484-8ccd3f80-c4ef-11e9-8d9f-2f06dc725fc7.png)

        > NOTE: Azure Devops forces a run so expect this to fail. Future steps will resolve this problem.


> The following CLI command(s) can be run as an alternative to using the portal-based instructions:

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

> The following CLI command(s) can be run as an alternative to using the portal-based instructions. Note this creates the Service Connection within Azure DevOps, but you will still need to setup the Service Principal:

```bash
az devops service-endpoint azurerm create --azure-rm-subscription-id $SUBSCRIPTION_ID --azure-rm-subscription-name "$SUBSCRIPTION_NAME" --azure-rm-tenant-id $TENANT_ID --azure-rm-service-principal-id $SERVICE_PRIN_ID --name "$SERVICE_CONN_NAME"
```

3. **Configure Azure Devops pipeline using Azure resource values**

    This step is about making sure Azure Devops references all the values and resources you took the time to create in the Azure portal.

    * Add the Azure Subscription being used for Cobalt as a *Service Connection*
        * Return to your Azure DevOps subscription
        * Find and select the Project Settings tab at the bottom of the screen
        * Under the Pipelines menu select Service Connections
        * From the Service Connections menu, select [+New Service Connection]
        * Choose Azure Resource Manager from the dropdown then a name for your service (ex. Cobalt Deployment Administrator-`<YourTenantName>`). The name should make sense to users and will be directly referenced in pipeline variable groups later.
        * Use the full version of the service connection dialog in order to enter your service principal credentials (AAD Key, AAD App ID, Tenant, etc.)

            ![Service Connection menu](https://user-images.githubusercontent.com/10041279/63485304-63b59c00-c468-11e9-8e47-721a2e43ecb9.png)

        * Verify and Save the connection
        > NOTE: Take note of the custom name given to this service connection. This will be referenced in later steps needed to configure env variable groups.

    * Enable multi-stage pipelines
        * Find your signed-in avatar/image and select preview features from the drop down menu

            ![Preview Features menu](https://user-images.githubusercontent.com/10041279/63486065-8eedba80-c46b-11e9-90f0-7f931f909ffa.png)

        * Toggle Multi-stage pipelines

    * Configure the variables needed by the pipeline. The latest configuration values are described in the [pipeline documentation](../devops/providers/azure-devops/README.md)

> **Note**: The following CLI command can be run as an alternative to using the portal-based instructions:

```bash
az pipelines variable-group create --authorize true --name "$VARIABLE_GROUP_NAME" --variables KEY1="VALUE1" ...
```

* Link Variable Groups for DevInt and Infrastructure to the Build Pipeline
    * Select Pipelines tab from within side-navigation menu
    * Select existing pipeline and then click [Edit]
    * Next to the [Variables] button at the top of the page, click the ellipses and select Triggers

        ![Triggers](https://user-images.githubusercontent.com/41071421/63284806-022fda80-c27a-11e9-8e23-494314c63651.png)

    * Navigate to the [Variables] tab and begin linking each variable group
    * Link each variable group, one by one

        ![Link Variable Groups](https://user-images.githubusercontent.com/10041279/63489261-3b816980-c477-11e9-87bf-1d254226e8fd.png)

    * Save the build pipeline

> The following CLI command(s) can be run as an alternative to using the portal-based instructions:

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

4. **Clone newly created Azure DevOps Repo from your organization**

    With this step, the goal is to pull down the repo into a local environment so that one can begin making code changes.

    * Visit your newly created repo and clone down the repo.

        ![git Clone button](https://user-images.githubusercontent.com/10041279/63484822-9f4f6680-c466-11e9-8aa5-13ad9ba763d9.png)

        ```bash
        $ git clone <insert-git-repo-url>
        ```

5. **Keep the templates relevant to your enterprise patterns**

    The goal of this step is to continue efforts removing infrastructure as code Cobalt templates that users have no interest in deploying.

    * Open the project from your favorite IDE and navigate to infrastructure templates `./infra/templates` directory.
    * Manually delete template directories not needed for your enterprise.
    > NOTE: Do not delete 'backend-state-setup' template! We also recommended keeping the 'az-hello-world' template as a starter template.
    * Commit the newly pruned project to your newly forked repo.
        ```bash
        $ git commit -m "Removed unrelated templates." && git push
        ```
    > NOTE: Integration tests running in the release stage of the pipeline may have resource group level naming conflicts if other tests of the same templates are also running or have been persisted in the Azure portal.

```bash
az pipelines run --name "$COBALT_PIPELINE_NAME"
```

## Conclusion

 Recommended next step is to either reference containerized applications by their image name from within a Cobalt template in order to run a deployment or to employ this repo as ground truth for acceptable patterns and versioning across an organization.
