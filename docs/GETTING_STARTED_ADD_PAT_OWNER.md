# Getting Started - Advocated Pattern Owner

## Cobalt Enterprise Integration - Overview

Completion of the steps from this document results in an Azure Devops Repo initialized with carefully selected Cobalt Advocated Pattern Templates (Infrastructure as code) along with a CI/CD pipeline ready for multi-stage deployments.

This document provides Cobalt users instructions for initializing and integrating Cobalt into their existing AzureDevops organization using an Azure subscription. These steps assume some basic familiarity with the Azure DevOps portal and a desire to automate the creation of infrastructure. For more information on Cobalt, visit the following link: [READ ME](../README.md)

### Prerequisites

  1. An Azure Subscription
  2. Azure Devops Organization
  3. Permissions to your Organization's Azure Devops account
  4. *Global administrator role* permissions in your Organization's Azure Active Directory tenant to setup service principals
    * If this is not allowed by your organization, step two and the Service Connection creation in step three will need to be completed by someone within your organization with this permission.

### STEPS

1. **Initialize Azure Repo Subscription with Cobalt**

    This step helps setup your Azure Devops repo with Cobalt Advocated Pattern Templates that matter to you. These are common instructions that are needed for any audience interested in using Cobalt for infrastructure automation.

    * Create a new project
        1. Sign-in to Azure DevOps (https://azure.microsoft.com/en-us/services/devops/)
        2. Create new project under Organization. First create new Organization if it don't exists already. (ex. Cobalt-Contoso)

            ![alt text](./images/Org.png "Create Organization")
            ![alt text](./images/project.png "Create Project")

    * Create new repository by fetching source code from the master branch of Cobalt's open-source github project
        1. Select Repos tab within side-navigation menu
        2. Select 'Import a repository' from the Repos tab sub-menu and click [Import]
        3. Enter the Cobalt Clone URL (https://github.com/microsoft/cobalt.git) and select Import

            ![Clone Button](https://user-images.githubusercontent.com/10041279/63459072-8ec4cf00-c419-11e9-8ef4-ee7db827e49c.png)

    * Rename your repository
        1. Click your Repo Name (ex. Cobalt-Contoso) at the top of the page.

            ![Repo Name dropdown](https://user-images.githubusercontent.com/10041279/63615290-9d8ebb80-c5aa-11e9-9136-64295640205b.png)

        2. Select Manage Repositories
        3. Under Git repositories, find "Cobalt-Contoso" and select the ellipses
        4. Select Rename repository

            ![Rename Repo dropdown](https://user-images.githubusercontent.com/10041279/63615540-3b828600-c5ab-11e9-9174-07f23b3193bf.png)

        5. Give it a new name and click [Rename]

            | Naming Recommendation  | Template Repo Strategy |
            |-------------|-----------|
            | Cobalt-Hello-World-Contoso | If the aim is to introduce oneself or the organization to Cobalt, we recommended a name that reflects the spirit of the Azure Hello World Cobalt template. |
            | Cobalt-AZ-ISO-Contoso | If the aim is to have a single repository represent a single Cobalt template, and thereafter, to have one repo per template, we recommend a name that reflects the Cobalt Template being deployed. In this naming example, the name assumes this repo will be dedicated to deploying the Cobalt *az-isolated-service-single-region* template |
            | Cobalt-Contoso | If the aim is to use a single repository as ground truth for all potential patterns across your organization, effectively having to manage a combination of Cobalt patterns from a single repo, it's recommended to stick with a name that matches the project name. |

    * Initialize new Azure Devops pipeline
        1. Select Pipelines tab from within side-navigation menu
           
           ![alt text](./images/pipline.png "Create Pipline")

        2. Select New Pipeline and then choose 'Azure Repos Git [YAML]'

            ![Pipeline Menu](https://user-images.githubusercontent.com/10041279/63459652-89b44f80-c41a-11e9-829a-05a6888b7673.png)

        3. Find and select the newly created repository from dropdown menu
        4. Import YAML by selecting 'Existing Azure Pipelines YAML file'
            * Enter the path to the devops yaml file that lives within your newly created repo. (i.e. devops/providers/azure-devops/templates/azure-pipelines.yml)

            ![Select YAML](https://user-images.githubusercontent.com/10041279/63459938-21b23900-c41b-11e9-9b9c-2dfa72e51350.png)

            > NOTE: Automatic drop-down does not always populate with yaml file options. It may be necessary to simply copy and paste the above path.
        5. Review devops pipeline YAML and only keep templates relevant to your enterprise patterns.
            * Remove jobName configurations not relevant to your enterprise patterns. If new to Cobalt, we recommend keeping the path to the az_hello_world template as a starter template. This step can also be completed later as a code commit to your repo. Below is an example of a jobName that you may want to remove by simple deleting it.
                ```yaml
                configurationMatrix:
                - jobName: az_service_single_region
                terraformTemplatePath: 'infra/templates/az-service-single-region'
                terraformWorkspacePrefix: 'sr'
                environmentsToTeardownAfterRelease:
                - 'devint'
                ```
        6. Save and run

            ![Fail Screenshot](https://user-images.githubusercontent.com/10041279/63546484-8ccd3f80-c4ef-11e9-8d9f-2f06dc725fc7.png)

            > NOTE: Azure Devops forces a run so expect this to fail. Future steps will resolve this problem.

2. **Provision Azure resources needed for Azure Devops pipeline**

    This step sets up all the values and resources that will serve as inputs to your test automation pipeline in Azure Devops. Without this setup step, you cannot deploy Cobalt templates to Azure Devops.

    * Create a registered Azure AD (AAD) app for Cobalt deployments
        1. Sign-in to your organization's Azure account. (https://portal.azure.com)
        2. Filter for Azure Active Directory and navigate to it's menu
        3. Select App registrations from the menu blade
           
           ![alt text](./images/appreg.png "App Registrations")

        4. Click [Add/+] New registration then enter a name for the application (ex. cobalt-hw-admin-sp-`<username>` or cobalt-az-iso-admin-sp-`<username>`)
        5. Choose single tenant as a supported account type
        6. Click Register

    * Setup permissions for the new AAD app to also use legacy API permissions
        1. From the App registrations service blade, select the API permissions
           
           ![alt text](./docs/images/apipermissions.png "API Permissions")

        3. Configure Azure Activity Directory Application permissions to ReadWrite.OwnedBy. First select Microsoft Graph and then select Application Permissions

            ![Request Permissions menu](https://user-images.githubusercontent.com/10041279/63549279-b6896500-c4f5-11e9-9c92-40ac2a4295c9.png)

        4. Click [Add permissions] to save this configuration
        5. Click [Grant admin consent for *Your Directory*] to grant consent on behalf of users in this directory for this permission 

    * Configure the new AAD app as a Cobalt admin service-principal/service-endpoint
        1. From the App registrations service blade, click the [Certificates & secrets] tab
        2. Click [+New client secret] from within the Client secrets menu then enter a description (ex. rbac)

            ![Client Secret menu](https://user-images.githubusercontent.com/10041279/63461963-69d35a80-c41f-11e9-8d4a-c72235177fb3.png)

        3. Click Add
            > IMPORTANT: Generate a secret that does not have a trailing slash. Secrets that lead with a slash (ex."/","\") may cause parsing errors.

            > NOTE: Take note of the generated client secret (only displayed once). This will be used for your Azure Devops Service Connection in step 3.
        4. From the App registrations service blade, select Overview.
            > NOTE: Take note of the Application (client) ID. This will also be used for your Azure Devops Service Connection in step 3.

    * Grant newly created Service Principal an Owner role to your preferred enterprise subscription.

        This elevates the Service Principal with more permissions so that Terraform can rely on this Service Principal as an Azure user for Cobalt template deployments.

        1. Filter for subscriptions and navigate to the subscriptions list
        2. Either choose a subscription or create a new one (ex. Cobalt-Contoso-Deployments)
        3. Select your chosen subscription then select the Access control (IAM) tab from the menu blade.
        4. Click [+/Add] and select Add role assignment
        5. From the sub-menu, select 'Owner' as a role from the drop down and search for the newly created Service Principal (i.e. cobalt-hw-admin-sp-`<username>` or cobalt-az-iso-admin-sp-`<username>`)

                ![Role Assignment menu](https://user-images.githubusercontent.com/31149154/63708249-7ed23400-c7f9-11e9-8dbb-c15dcdaf3a37.png)

        6. Click Save

    * Create Resource Group and Storage Account for backend state
        1. Filter for Storage accounts and navigate to the storage account list
        2. Click [+/Add] and enter values for the following fields:
            * Subscription: Your preferred enterprise subscription for Cobalt template deployments
            * Resource group: Create new (ex. cobalt-devint-hw-admin-rg or cobalt-devint-az-iso-admin-rg )
            * Storage account name: (ex. cobalttfstates)
        3. Click [Review+Create] then [Create]
        4. Once deployment for storage account is completed, go to the resource and visit the Blobs sub-menu
        5. Click [+Container] then create a container name (ex. az-hw-remote-state-container or az-iso-remote-state-container) with private access

3. **Configure Azure Devops pipeline using Azure resource values**

    This step is about making sure Azure Devops references all the values and resources you took the time to create in the Azure portal.

    * Add the Azure Subscription being used for Cobalt as a *Service Connection*
        1. Return to your Azure DevOps subscription
        2. Find and select the Project Settings tab at the bottom of the screen
        3. Under the Pipelines menu select Service Connections
        4. From the Service Connections menu, select [+New Service Connection]
        5. Choose Azure Resource Manager from the dropdown then a name for your service (ex. Cobalt Deployment Administrator-`<YourTenantName>`). The name should make sense to users and will be directly referenced in pipeline variable groups later.
        6. Use the full version of the service connection dialog in order to enter your service principal credentials (AAD Key, AAD App ID, Tenant, etc.)

            ![Service Connection menu](https://user-images.githubusercontent.com/10041279/63485304-63b59c00-c468-11e9-8e47-721a2e43ecb9.png)

        7. Verify and Save the connection
        > NOTE: Take note of the custom name given to this service connection. This will be referenced in later steps needed to configure env variable groups.

    * Enable multi-stage pipelines
        1. Find your signed-in avatar/image and select preview features from the drop down menu

            ![Preview Features menu](https://user-images.githubusercontent.com/10041279/63486065-8eedba80-c46b-11e9-90f0-7f931f909ffa.png)
            ![Preview Features menu](./docs/images/preview.png)

        2. Toggle Multi-stage pipelines

    * Configure *Infrastructure Pipeline Variables* as the first of two variable groups
        1. Select Pipelines tab from within side-navigation menu then select Library tab
        2. Click [+Variable group] and name it "Infrastructure Pipeline Variables"
        3. Add the following variables:

            | Name   | Value | Var Description |
            |-------------|-----------|-----------|
            | `AGENT_POOL` | Hosted Ubuntu 1604 | The type of build agent used for your deployment. |
            | `ARM_PROVIDER_STRICT` | false | Terraform ARM provider modification |
            | `BUILD_ARTIFACT_NAME` | drop | Name to identity the folder containing artifacts output by a build. |
            | `GO_VERSION`| 1.12.5 | The version of Go terraform deployments are bound to. |
            | `PIPELINE_ROOT_DIR` | devops/providers/azure-devops/templates/ | A path for finding Cobalt templates. |
            | `REMOTE_STATE_CONTAINER` | `<CONTAINER_NAME>`| The remote blob storage container name for managing the state of a Cobalt Template's deployed infrastructure. Also is used as a naming convention for partitioning state into multiple workspaces. This name was created in an earlier step from within the azure portal. |
            | `SCRIPTS_DIR` | infrastructure/scripts | Path to scripts used at runtime for composing build and release jobs at various pipeline stages. |
            | `TEST_HARNESS_DIR` | test-harness/ | A path to the cobalt test harness for running integration and unit tests written in Docker and Golang. |
            | `TF_ROOT_DIR`| infra | The primary path for all Cobalt templates and the modules they are composed of. |
            | `TF_VERSION`| 0.12.4 | The version of terraform deployments are bound to. |
            | `TF_WARN_OUTPUT_ERRORS`| 1 | The severity level of errors to report. |

    > Important: Every targeted environment specified within the build pipeline expects a
    > variable group specified with the naming convention `<ENVIRONMENT_NAME> Environment Variables`

    * Configure *DevInt Environment Variables* as the final variable group
        1. Environment-specific variables have no default values and must be assigned
        2. Return to the Library tab
        3. Click [+Variable group] and name it *DevInt Environment Variables*
        4. Add the following variables:

            | Name  | Value | Var Description |
            |-------------|-----------|-----------|
            | `ARM_SUBSCRIPTION_ID` | `<ARM_SUBSCRIPTION_ID>` | The Azure subscription ID for which all resources will be deployed. Refer to the Azure subscription chosen in Azure portal for Cobalt deployments. |
            | `REMOTE_STATE_ACCOUNT` | `<AZURE_STORAGE_ACCOUNT_NAME>` | The storage container account name created in a previous step that is used to manage the state of this deployment pipeline. The storage Account is shared among all non-prod deployment stages. |
            | `SERVICE_CONNECTION_NAME` | ex. Cobalt Deployment Administrator-`<TenantName>` | The custom name of the service connection configured in a previous Azure Devops step that establishes a connection between the Service Principal and the Azure subscription that it's permissioned for. |

    * Additional Setup Instructions per Template

        Select Cobalt templates require additional pipeline setup. Please complete extended steps if chosen template resides in the below list.

        1. az-isolated-service-single-region
            1. Create ASE w/ VNET
            2. Add additional env vars to *Infrastructure Pipeline Variables* group

                | Name  | Value | Var Description |
                |-------|-------|-----------------|
                | `TF_DEPLOYMENT_TEMPLATE_ROOT` | infra/templates/az-isolated-service-single-region | Pipeline reference for relative location of this template |

    * Link Variable Groups for DevInt and Infrastructure to the Build Pipeline
        1. Select Pipelines tab from within side-navigation menu
        2. Select existing pipeline and then click [Edit]
        3. Next to the [Variables] button at the top of the page, click the ellipses and select Triggers

            ![Triggers](https://user-images.githubusercontent.com/41071421/63284806-022fda80-c27a-11e9-8e23-494314c63651.png)

        4. Navigate to the [Variables] tab and begin linking each variable group
        5. Link each variable group, one by one

            ![Link Variable Groups](https://user-images.githubusercontent.com/10041279/63489261-3b816980-c477-11e9-87bf-1d254226e8fd.png)

        6. Save the build pipeline

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

## Conclusion

 Recommended next step is to either reference containerized applications by their image name from within a Cobalt template in order to run a deployment or to employ this repo as ground truth for acceptable patterns and versioning across an organization.
