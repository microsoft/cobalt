# 2. Quickstart Guide

## 2.1 Overview

*Cobalt* is an open-source tool for developers who are interested in reusing or contributing new cloud infrastructure as code patterns in template form. A major core feature of Cobalt is that it offers a library of Terraform based modules that allow you to create and build-up what we are calling *Cobalt Infrastructure Template*s or *CIT*s (/kɪt/). To find out more about the Cobalt Modules that make up our *Cobalt Infrastructure Template*s, visit *[Cobalt Templating from Scratch](./3_NEW_TEMPLATE.md)*.

You can get pretty creative and build your own custom *CIT*s in order to use and/or contribute to Cobalt but we strongly recommend that you first complete this quickstart guide. This guide is centered around our existing [*Azure Hello World CIT*](../infra/templates/az-hello-world/README.md "AZ Hello World - Cobalt Infrastructure Template") and should serve as your first Azure infrastructure deployment. This *CIT* is composed of our App Service Plan and App Service module. In summary, completing this guide should be your first major step in familiarizing yourself with Cobalt and the *CIT* developer workflow. Welcome to Cobalt! 😄

> For a more general overview of Cobalt, please visit our main page: [READ ME](../README.md "Main Cobalt Read Me")

## 2.2 Goals and Objectives

🔲 Prepare local environment for running *Cobalt Infrastructure Template*s.

🔲 Run the [*Azure Hello World CIT*](../infra/templates/az-hello-world/README.md "AZ Hello World - Cobalt Infrastructure Template") to create an [Azure Resource Group](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-overview) with an [App Service Plan](https://docs.microsoft.com/en-us/azure/app-service/overview-hosting-plans), an [App Service Staging Slot](https://docs.microsoft.com/en-us/azure/app-service/deploy-staging-slots), and [App Service](https://docs.microsoft.com/en-us/azure/app-service/) running a public docker container.

🔲 Walk away with a introductory understanding of the *CIT* developer workflow.

🔲 Feel confident in moving forward to our next recommended section: *[Cobalt Templating from Scratch](./3_NEW_TEMPLATE.md).*

## 2.3 Prerequisites

> **NOTE:** Previous "infrastructure as code" experience is not a prerequisite for completing the quickstart guide.

| Prereqs | Description |
|----------|--------------|
|Azure Subscription |[Azure Portal](https://portal.azure.com/) - This template needs to deploy infrastructure within an Azure subscription.|
|Azure Service Principal|[Azure Service Principal](https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal) - This template needs permissions to deploy infrastructure within an Azure subscription.|
|Azure Storage Account|[Azure Storage Account](https://docs.microsoft.com/en-us/azure/storage/common/storage-account-overview) - An account for tracking Terraform remote backend state. You can use our backend state setup [template](../infra/templates/backend-state-setup/README.md) to provision the storage resources.|
|Azure CLI (`Latest`)|[Get started with Azure CLI](https://docs.microsoft.com/en-us/cli/azure/get-started-with-azure-cli?view=azure-cli-latest) - The Azure CLI is a dependency of the Terraform templates used in Cobalt.|
|GitHub Account|[Github](https://github.com/login) - An account for forking the Cobalt repo.|
|Terraform `(0.12 +)`|[Terraform](https://www.terraform.io/downloads.html) - Download the appropriate version for setting up Terraform.|
|Git Source Control|[Install git](https://git-scm.com/downloads).|
|Terminal with bash shell|[WSL](https://code.visualstudio.com/docs/remote/wsl) or [Bash](https://git-scm.com/downloads) - The shell environment needed to follow along with the provided instructions. *In Windows, we recommend Visual Studio Code integrated WSL*.|
---

## 2.4 Walkthrough - Running Cobalt's [_Azure Hello World CIT_](../infra/templates/az-hello-world/README.md)

Below are the steps for running the [_Azure Hello World CIT_](../infra/templates/az-hello-world/README.md) from your terminal. Ensure that running this template achieves the quickstart guide's final goal of deploying the following Azure cloud infrastructure before you can call this quickstart guide finished:

| Quickstart Steps Preview | Deployment Goal |
|----------|--------------|
|![cobalt-'NickeManarin/Screen2Gif-100secs'](./Cobalt-QS.gif)| <image src="https://user-images.githubusercontent.com/10041279/66678697-149f1280-ec32-11e9-9bbb-c94a8111115b.png" width="1400"/> |

### **Step 1:** Fork Cobalt Repo

Initializing a repository that you own and control is recommended. Once forked, move onto the next step.

* From any page within this repository, find the forked menu and fork the repo into your own repository.

    ![image](https://user-images.githubusercontent.com/10041279/66366857-6e17f080-e957-11e9-8b32-266b0d4a98fc.png)

### **Step 2:** Clone Repo to Local Environment

You will be creating Azure infrastructure by running Cobalt CITs from your local environment so you will need to have a copy of the Cobalt project locally.

* From any terminal with git, use the following git command to clone your forked repo into your local environment. You can find your git repo url at the landing page of your forked repo.

    ```bash
    git clone <insert-forked-git-repo-url> # ex. git clone https://github.com/<YourGitAccout>/cobalt.git
    ```

### **Step 3:** Setup Local Environment Variables

You'll need to define a `.env` file in the root of your local project. This will hold all the environment variables needed to run your Cobalt CITs locally. You will be using our [environment template file](../.env.template) to start.

1. Navigate to the root directory of your project and use the following command to copy the environment template file.

    ```bash
    cp .env.template .env
    ```

    ```bash
    $ tree cobalt
    ├───.env.template
    ├───.env ## New file generated from the command
    └───infra
          ├───modules
          │   └───providers
          │       ├───azure
          │       │   ├───...
          │       │   └───vnet
          │       └───common
          └───templates
              ├───az-hello-world
              │   └───test
              └───backend-state-setup
    ```

1. Provide values for the environment values in `.env`. These are required to authenticate Terraform to provision resources within your subscription.

1. Navigate to the root directory and execute the following commands to set up the environment variables for your wsl session:

    ```bash
    # These commands setup all the environment variables needed to run this template.
    DOT_ENV=.env
    export $(cat $DOT_ENV | grep -v '^\s*#' | xargs)
    ```

    > **NOTE:** These environment variables will not persist past the current terminal session and will need to be re-exported per session. In addition, any updates to the .env file will require re-exporting the environment variables.

1. Execute the following login command to configure your local Azure CLI.

    ```bash
    # This logs your local Azure CLI in using the configured service principal.
    az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID
    # Sanity check your login.
    az account show
    ```

### **Step 4:** Initialize a Terraform Remote Workspace

A Terraform workspace is primarily a state file generated by the `terraform init` and/or `terraform workspace new` commands. This [state](https://www.terraform.io/docs/state/index.html) file is maintained by Terraform and it tracks important information about the resources that it has provisioned. It is a critical component to Terraform and it is worth understanding, but this will not be covered here.

A best practice when using Terraform is to store state files in the cloud (i.e., Azure Blob Storage or AWS S3). In this example, we will configure a new state file in the cloud, a Terraform **remote** workspace that will be persisted in Azure Blob Storage. Terraform uses your Azure blob storage account and storage container created from the [prerequisites](#2.3-prerequisites).

* Navigate to the az-hello-world directory (i.e. ./infra/templates/az-hello-world) and execute the following commands to set up your remote Terraform workspace.

    ```bash
    # This configures Terraform to leverage a remote backend that will help you
    # and your team keep consistent state. It will also load any modules that are being referenced by a CIT.
    terraform init -backend-config "storage_account_name=${TF_VAR_remote_state_account}" -backend-config "container_name=${TF_VAR_remote_state_container}"

    # This command configures Terraform to use a workspace unique to you.
    # This allows you to work without stepping over your teammate's deployments.
    terraform workspace new "az-hw-$USER" || terraform workspace select "az-hw-$USER"
    ```

    ```bash
    $ tree cobalt
    ├───.env.template
    ├───.env
    └───infra
          ├───modules
          └───templates
              ├───az-hello-world
              │   └───.terraform # New local directory generated by 'terraform init' (holds workspace artifacts).
              └───backend-state-setup
    ```

### **Step 5:** Run Cobalt's [_Azure Hello World CIT_](../infra/templates/az-hello-world/README.md)

This is the step that demonstrates what the [_Azure Hello World CIT_](../infra/templates/az-hello-world/README.md) has to offer as it deploys actual Azure cloud resources.

You will notice that the naming conventions for the resources in Azure have been generated using the workspace name configured in the last step. This is a key component to CITs and is used by the Cobalt deployment templates to isolate infrastructure resources across devint, qa and production stages.

* From the az-hello-world directory, execute the following commands to run a template and orchestrate a deployment.

    ```bash
    # Ensure that the current workspace is az-hw-$USER.
    terraform workspace show

    # See what terraform will try to deploy without actually deploying.
    terraform plan

    # Run Azure Hello World CIT to execute a deployment.
    terraform apply
    ```

* **Azure Hello World CIT [Main.tf](../infra/templates/az-hello-world/main.tf) File - Preview**

    A template is made up of custom modules and has several files. The main file that drives this template's deployment is the Main.tf Terraform file:

    ```HCL
    resource "azurerm_resource_group" "main" {
        name     = local.app_rg_name
        location = local.region
    }
    // module instantiation
    module "service_plan" {
        source              = "../../modules/providers/azure/service-plan"
        resource_group_name = azurerm_resource_group.main.name
        service_plan_name   = local.sp_name
    }
    // module instantiation
    module "app_service" {
        source                           = "../../modules/providers/azure/app-service"
        app_service_name_prefix          = local.app_svc_name_prefix
        service_plan_name                = module.service_plan.service_plan_name
        service_plan_resource_group_name = azurerm_resource_group.main.name
        docker_registry_server_url       = local.reg_url
        app_service_config               = local.app_services
    }
    ```

### **Step 6:** Validate Infrastructure Deployed Successfully

If you correctly completed the previous step, you can trust that Azure resources are now living in Azure. However, let's take it a step further and get your eyes on the infrastructure that was just created. Seeing the end result gives you the full quickstart experience and is something that should be done for all future Cobalt CIT executions.

1. Login to the Azure Portal.
1. Search for "Resource Group" to find the Resource Group menu.
1. Find and Select the name of the Resource Group created from running the Azure Hello World CIT.
1. Select the App Service created from running the template.

    ![az_quick_start_resources](https://user-images.githubusercontent.com/10041279/66673240-c84dd580-ec25-11e9-9ef7-f3022171b124.png)

1. Select the "overview" tab.
1. Wait for the App Service "URL" link to display itself from within the menu and then visit the link.

    <image src="https://user-images.githubusercontent.com/10041279/66673683-ac96ff00-ec26-11e9-812f-2b1d7e0b3d25.png" width="460"/>

### **Final Step:** Teardown Infrastructure Resources

The infrastructure created from running the Azure Hello World CIT is no longer needed. It's functional but is primarily for the quickstart guide. Complete the following steps to delete the resources referenced in your remote workspace:

1. From within the Azure portal, visit the Azure blob storage state file (i.e. "az-hw-$USER") and view it's contents. This file remotely holds the state of your deployed Azure infrastructure. The next step will wipe out the contents of this workspace file along with the associated infrastructure resources.

1. Locally, from the az-hello-world directory, execute the following command to delete your resources by tearing down your deployment.

    ```bash
    terraform workspace select az-hw-$USER
    # Teardown deployment. Only do this if you want to delete your resources.
    terraform destroy
    ```

1. From within the Azure portal, revisit the Azure blob storage Terraform state file (i.e. "az-hw-$USER") and view it's contents. At this point, this workspace file should have an empty state. Now it can be deleted.

    ```bash
    terraform workspace select default
    # Delete the workspace artifacts on blob storage
    terraform workspace delete az-hw-$USER
    ```

1. Delete the local workspace directory created from running the 'terraform init' command in an earlier step.

    ```bash
    $ tree cobalt
    ├───.env.template
    ├───.env
    └───infra
          ├───modules
          └───templates
              ├───az-hello-world
              │   └───.terraform # Removing this directory
              └───backend-state-setup
    ```

    ```bash
    rm -rf .terraform
    ```

## Experiencing errors?

If you're having trouble, the below documented errors may save you some time and get you back on track.

* **Misconfigured deployment service principal**: If you're seeing the following error, the deployment service principal needed for the Terraform AzureRM provider is misconfigured.

    ![image](https://user-images.githubusercontent.com/10041279/72762825-ab228e80-3ba6-11ea-96cf-489301bae4c5.png)

    There are several ways to authenticate with the Azure provider, our recommended way is to use the .env file for _Authenticating to Azure using a Service Principal and a Client Secret_. The .env file environment variables have to be exported prior to running "terraform init". Revisit step 3 and/or visit this link for Terraform specific instructions: https://www.terraform.io/docs/providers/azurerm/guides/service_principal_client_secret.html 

## Conclusion

Completion of this quickstart guide means that you have used the Azure Hello World CIT to deploy Azure infrastructure from your local device. You have also torn down the infrastructure along with the associated workspace files created for managing the state of the infrastructure. These steps have effectively been an introductory exercise of Cobalt's CIT (/kɪt/) Developer Workflow. (i.e. create/choose a template ---> init ---> workspace (local or remote) ---> apply ---> plan ---> destroy). You should already be familiar with this workflow if you've had prior experience deploying infrastructure using Terraform.

### **Recommended Next Step:** *[Cobalt Templating from Scratch](./3_NEW_TEMPLATE.md).*
