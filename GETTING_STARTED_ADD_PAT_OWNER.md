# Getting Started - Advocated Pattern Owner

## Overview

This section provides Cobalt users instructions for initializing and integrating Cobalt into their AzureDevops subscription.

## Prerequisites

  * An Azure Subscription
  * Azure Devops Organization
  * Permissions to your Organization's Azure Devops account

### Cobalt Enterprise Integration

1. Initialize Azure Repo Subscription with Cobalt

    * Create a new project
        * Sign-in to Azure DevOps (https://azure.microsoft.com/en-us/services/devops/)
        * Select New project and create a name. (ex. Cobalt-Hello-World-Contoso)
            * NOTE: If you already have a Cobalt template in mind, it may be a good idea to express that in the name.
        * Select Create
            * ![image](.Create_new_project.png)

    * Create new repository by fetching source code from Cobalt's master project
        * Select Repos tab within side-navigation menu
        * Select 'Import a repository' from the Repos tab sub-menu
        * Enter the Cobalt Clone URL (https://github.com/microsoft/cobalt.git) and select Import
            * ![image](.Import-succesfull-image.png)

    * Initialize new Azure Devops pipeline
        * Select Pipelines tab from within side-navigation menu
        * Select New pipeline and then choose 'Azure Repos Git [YAML]'
        * Find and select the newly created repository from dropdown menu
        * Import YAML by selecting 'Existing Azure Pipelines YAML file'
            * Enter the path to the devops yaml file that lives within your newly created repo. (i.e. devops/providers/azure-devops/templates/azure-pipelines.yml)
            * ![image](.Select-YAML-file.png)
        * Review devops pipeline YAML and only keep templates relevant to your enterprise patterns.
            * Remove jobName configurations not relevant to your enterprise patterns.
                ```yaml
                configurationMatrix:
                - jobName: az_service_single_region
                terraformTemplatePath: 'infra/templates/az-service-single-region'
                terraformWorkspacePrefix: 'sr'
                environmentsToTeardownAfterRelease:
                - 'devint'
                ```
            * NOTE: If new to Cobalt, we recommend keeping the az_hello_world template as a starter template. This step can also be completed later as a code commit to your repo.
        * Save and run
            * NOTE: Azure Devops forces a run so expect this to fail. Future steps will solve this problem.

2. Provision Azure resources needed for Azure Devops pipeline

    * Create a Cobalt admin service-principal/service-endpoint for Cobalt deployments
        * Sign-in to your organization's Azure account. (https://portal.azure.com)
        * Filter for Azure Active Directory and navigate to it's menu
        * Select App registrations from the menu blade
        * Click [Add/+] New registration then enter a name for the application (ex. cobalt-hw-admin-sp)
        * Choose single tenant as a supported account type to keep things simple.
        * Click Register

    * Configure the newly created registered app as a Service Principal
        * From the app's service blade, select the Certificates & Secrets tab
        * Click [Add/+] New from within Client secrets menu then enter a description (ex. rbac)
        * Click Add
            * NOTE: Take note of the generated client secret (only displayed once).
        * From the app's service blade, select Overview. Take note of the Application (client) ID for the next step.

    * Grant newly created Service Principal a Contributor role to your preferred enterprise subscription
        * Filter for subscriptions and navigate to the subscriptions list
        * Either choose a subscription or create a new one
        * Select your chosen subscription then select the Access control (IAM) tab from the menu blade.
        * Click [+/Add] and select Add role assignment
            * From the sub-menu, select 'Contributor' as a role from the drop down and search for the newly created Service Principal (i.e. cobalt-hw-admin-sp)
            * Click Save
            * ![image](.role-assignment-menu.png)

    * Create Resource Group and Storage Account for backend state
        * Filter for Storage accounts and navigate to the storage account list
        * Click [+/Add] and enter values for the following fields:
            * Subscription: Your preferred enterprise subscription for Cobalt
            * Resource group: Create new (ex. cobalt-devint-admin-rg)
            * Storage account name: (ex. cobalttfstates)
        * Click [Review+Create] then [Create]
        * Once deployment for storage account is completed, go to the resource and visit the Blobs sub-menu
        * Click [+Container] then create a container name (ex. az-hw-remote-state-container ) with private access

3. Configure Azure Devops pipeline using Azure resource values from previous steps

    * Configure Global Pipeline Variables
        * Return to your Azure DevOps subscription
        * Select Pipelines tab from within side-navigation menu then select Library tab
        * Click [+Variable group] and add the following variables:

            | Name   | Value | Description
            |-------------|-----------|-----------|
            | `AGENT_POOL` | Hosted Ubuntu 1604 | The type of build agent used for your deployment. |
            | `ARM_PROVIDER_STRICT` | false | Terraform ARM provider modification |
            | `BUILD_ARTIFACT_NAME` | drop | Name to identity the folder containing artifacts output by a build. |
            | `GO_VERSION`| 1.12.5 | The version of Go terraform deployments are bound to. |
            | `PIPELINE_ROOT_DIR` | 'devops/providers/azure-devops/templates/' | A path for finding Cobalt templates. |
            | `REMOTE_STATE_CONTAINER` | az-hw-remote-state-container | The remote storage container name for managing the state of a cobalt template's deployed infrastructure. Also is used as a naming convention for branching state into multiple workspaces. |
            | `SCRIPTS_DIR` | infrastructure/scripts | Path to scripts used at runtime for composing build and release jobs at various pipeline stages. |
            | `TEST_HARNESS_DIR` | test-harness/ | A path to the cobalt test harness for running integration and unit tests written in Docker and Golang. |
            | `TF_ROOT_DIR`| infra | The primary path for all Cobalt templates and the module they are made of.  |
            | `TF_VERSION`| 0.12.4 | The version of terraform deployments are bound to. |
            | `TF_WARN_OUTPUT_ERRORS`| 1 | The severity level of errors to report |

    * Configure DevInt Pipeline Variables
        * ..

    * Configure QA Pipeline Variables
        * ..

    * Fill in env vars for three variables groups (QA, DevInt, Global)
        * Return to your Azure DevOps subscription
        * Select pipelines tab from within side-navigation menu
        * Select existing pipeline and then click [Edit]
        * Next to the [Variables] button at the top of the page, click the ellipses and select Triggers at the top of the page
        * ..

3. Clone newly created azure devops repo from your organization.
    * Visit your newly cloned repo and clone down the repo. (![image](.GitHub-Clone-Button.gif))
        ```bash
        $ git clone <insert-git-repo-url>
        ```

4. Keep the templates relevant to your enterprise patterns.
    * Open the project from your favorite IDE and navigate to infrastructure templates "./infra/templates."
    * Cherry pick template directories to be deleted and manually delete each one at a time.
    * Commit the newly pruned project to your newly forked repo.
        ```bash
        $ git commit -m "Removed unrelated templates." && git push
        ```
    NOTE: Do not delete 'backend-state-setup' template! We also recommended keeping the 'az-hello-world' template as a starter template.