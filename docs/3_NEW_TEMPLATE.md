# 3. Cobalt Templating From Scratch

## 3.1 Overview

Per the [quickstart guide](./2_QUICK_START_GUIDE.md), we demonstrated how easy it is to deploy an existing *Cobalt Infrastructure Template* or *CIT* (/kɪt/). However, it is likely that you will need to develop your own custom *CIT* by composing together the foundational infrastructure modules that ship with *Cobalt* or by building your own modules. This guide will walk you through building a *Cobalt Infrastructure Template* from scratch in order to cultivate a deeper understanding of what *Cobalt* has to offer.

A core feature of *Cobalt* is that it offers a library of Terraform based *Cobalt Module*s that you can compose to build-up *CIT*s. *Cobalt Module*s make full use of [Terraform Modules](https://www.terraform.io/docs/configuration/modules.html). The primary purpose of a Terraform Module as a feature is to define parts of your potential infrastructure configuration as re-usable units. They distill the otherwise complicated task of properly configuring a set of related resources for any particular use case in a re-usable way.

CIT's can reference both *Cobalt Module*s and Terraform modules that you create. The below table demonstrates how our current [Azure service-plan](./../infra/modules/providers/azure/service-plan/README.md) Cobalt Module is being reused by several out of the box CIT's:

| Cobalt Infrastructure Template | CIT referencing an [Azure service-plan](./../infra/modules/providers/azure/service-plan/README.md) Module |
|----------|----------|
|[az-hello-world](./../infra/templates/az-hello-world/README.md)| ![image](https://user-images.githubusercontent.com/10041279/67301762-82123500-f4b5-11e9-9bff-8dc07a4fe001.png) |
|[az-service-single-region](./../infra/templates/az-hello-world/README.md)| ![image](https://user-images.githubusercontent.com/10041279/67302608-bf2af700-f4b6-11e9-9add-846bd2df42be.png) |
|[az-isolated-service-single-region](./../infra/templates/az-hello-world/README.md)| ![image](https://user-images.githubusercontent.com/10041279/67302203-2ac09480-f4b6-11e9-839f-19d40abd51ae.png) |

Building a template will always involve thoughtfully choosing a mix of *Cobalt Module*s that already exist or were created by you. This section of the walkthrough will be an exercise in building *CIT*s for Cobalt. Happy templating! 😄

> *Have you completed the quickstart guide? Deploy your first infrastructure as code project with Cobalt by following the [quickstart guide](./2_QUICK_START_GUIDE.md).*

## 3.2 Goals and Objectives

🔲 Demonstrate how to create Terraform based *Modules* and *CIT*s that work for your custom infrastructure scenario.

🔲 Improve your understanding of how to use existing *Cobalt Module*s and *CIT*s.

🔲 Feel confident in moving forward to our next recommended section: *[Testing Cobalt Templates](./4_TEMPLATE_TESTING.md).*

## 3.3 Prerequisites

| Prereqs | Description |
|----------|--------------|
| [Quickstart Guide](./2_QUICK_START_GUIDE.md) | The quickstart guide provides all of the prerequisites you'll need to create your own *CIT* and run it.|
| [Terraform Modules](https://www.terraform.io/docs/configuration/modules.html) | An introductory understanding of Terraform modules.|

## 3.4 Walkthrough - Creating a New Template

Experience what it's like to create your own *CIT* from scratch by following the below steps:

### **Step 1:** Model your planned infrastructure

For demonstration purposes, we have already modeled the infrastructure. You will build a *CIT* and title it **az-walkthrough-cit** within your codebase. This CIT when ran will create and deploy the Azure resources listed in the description of the below table:

| New CIT Name | Description | Deployment Goal |
|----------|----------|----------|
| **az-walkthrough-cit** | A Cobalt Infrastructue Template that when ran creates a basic [Azure Function App](https://docs.microsoft.com/en-us/azure/azure-functions/functions-overview) within an [App Service Plan](https://docs.microsoft.com/en-us/azure/app-service/overview-hosting-plans) accompanied with [Azure Storage](https://azure.microsoft.com/en-us/services/storage/blobs/). | <image src="https://user-images.githubusercontent.com/10041279/73130313-83269700-3fbb-11ea-90d5-7d785d3aeb8c.png" width="500" height="200"/> |

### **Step 2:** Plan your module strategy

Once you've modeled your planned infrastructure resources, we recommend answering the following questions:

1. > QUESTION: **"Which portion of my planned infrastructure do I want to roll-up into a re-usable module?"**

    **ANSWER:** Currently, most Cobalt Modules are scoped to a very specific cloud infrastructure resource. In other words, modules encapsulate a configuration that targets a providers very specific cloud service product. The Walkthrough Module we are creating will follow this pattern as it will be scoped to an Azure Function.

1. > QUESTION: **"Does Cobalt have existing re-usuable modules configured for any portion of my planned infrastructure?"**

    **ANSWER:** At the time of this walkthrough, there's a reusable Cobalt Module for an Azure App Service Plan, so you will use this to build part of your Azure Walkthrough *CIT*. However, for demonstration purposes we also will need to build one from scratch. Let's start by designing one before we implement it!

### **Step 3:** Design Your Terraform Based *Module*s

The three steps needed to design a *Module* involve defining each of a Terraform module's 3 primary elements: input variables, output variables and resources. This will be all done via Terraform's [HCL language](https://learn.hashicorp.com/terraform), a declarative language that grants developers the ability to target multiple cloud providers. Documentation for the HCL language is partitioned by cloud provider. You will become very familiar with Terraform's cloud provider documentation as you learn to use and build your own modules and CITs.

1. **Visit the below link**. Use the documentation hosted at the below link for a reference into how we are making the below design decisions for the *Walkthrough Module*.

    * Terraform - [Azure ARM Provider - Azure Function](https://www.terraform.io/docs/providers/azurerm/r/function_app.html#example-usage-in-a-consumption-plan-)

1. **Define your resources** - This is the first step in designing a module. Below are several steps you can take for defining your Terraform resources.

    1. Find your main Terraform resource.
        * In this case, we are building a Walkthrough Module that defines configuration for an Azure Function. Therefore, our main Terraform resource is `azurerm_function_app`.
    2. Look for other Terraform resource dependencies in relation to the main Terraform resource.
        * Helpful links.
            - [Azure Resource Explorer](https://resources.azure.com/)
            - [GitHub](https://github.com/search)
    3. Describe all of your discovered dependencies. Think about how they map to the planned infrastructure in Step 1 of this walkthrough. Here's what we are planning for the Walkthrough Module.

        | Resource | Description |
        |--------|-------------|
        | azurerm_function_app | According to the Terraform docs, this is the only resource unique to an Azure Function. This resource block will be declared within the module. |
        | azurerm_app_service_plan | The azure function app needs to live within an app service plan. Here we have a chance to reuse the existing Cobalt module that defines the app service plan. |
        | azurerm_storage_account | The azure function app's inherent ephemeral state needs a dedicated storage account. In this case, the existing storage account module will not be used to satisfy this dependency due to missing connection string outputs at the time of this write-up.  |
        | azurerm_resource_group | Most Azure infrastructure lives in a resource group container so this will be a part of the configuration as well.  |

1. **Define inputs** - When a CIT declares a module, it will configure the module using the module's exposed input variable names. These variables will pass values to the attributes of the resource blocks internal to the module. These inputs have also been defined for you below:

    | public input variable names | scope | default value | module input source/dependency (Source satisfying the public inputs) | Description  |
    |--------|-------------|-------------|-----------|-----------|
    | name | non-conditional | no | template | A name for the function app and how it will be identified within your Azure subscription. This will satisfy the `name` attribute of the `azurerm_function_app` resource. |

 
    | Private variable names | Scope |  | Required Public Input (no=has defaults) | Description (satisfies the x internal resource attribute foo) |
    |--------|-------------|-------------|-----------|-----------|

    | *azurerm_function_app* resource attribute | Scope | Required | Input Variable Name | Description |
    |--------|-------------|-------------|-----------|-----------|
    | name | Input | yes | `azure_function_name` | A name for the function app and how it will be identified within your Azure subscription. |
    | name | Input | yes | `azure_function_name_prefix` | A prefix name for appending unique values to the azure function name. |
    | resource_group_name | Input | yes | `resource_group` | Most Azure infrastructure lives in a resource group container of your choice. By making this an input, each module can have a different resouce group. |
    | location | Input | yes | `resource_group_location` | The geo-location here should derive from the geo-location that the resource group name lives in. |
    | app_service_plan_id  | Input | yes | `app_service_plan_id` | This input implies that the azure function resource will live within an app service plan. |
    | storage_connection_string | Input | yes | `storage_connection_string` | This is the storage account in which the ephemeral state for an Azure Function will be orchestrated when the endpoint is invoked. |
    | app_settings | Internal | no | `-` | { environment = "hw-from-scratch" } - We will provide a hard-coded key-value pair as an example that does not require an input. Value will not be passed from a CIT. |

1. **Define outputs** - A module will only output values that it's been pre-configured to output. It's **best practice** to configure module outputs because it enables module composition. These outputs are defined for you below:

    | *azurerm_function_app* attribute | Scope | Required | Output Variable Name | Description |
    |--------|-------------|-------------|-----------|-----------|
    | id | Output | no | `azure_function_id` | This is the ID output by the function app and used within your Azure subscription. |
    | default_hostname | Output | no | `azure_function_url` | This is the url endpoint output by the Azure Function app. |
    | kind | Output | no | `app_service_type` | This should output "functionapp". | 

    > **NOTE:** In this case, no attributes are required because no other resources in the CIT will depend on the output of the module.

### **Step 4:** Implement Your Terraform Based *Module*s

Let's implement the Walkthrough Module and integrate the input variables, output variables and resources defined in the previous step.

1. Navigate to the azure providers directory (i.e. ./infra/modules/providers/azure) and execute the following commands to wire up your new module:

    ```bash
    # Create a directory called "walkthrough-module"
    mkdir -p ./walkthrough-module
    # Navigate to that directory
    cd walkthrough-module
    # Create a main.tf, variables.tf and output.tf
    touch main.tf && touch variables.tf && touch output.tf
    ```

1. Open the variables.tf and paste the following:

    ```json
    //These are the Azure Function inputs for configuring your Walkthrough Module
    variable "azure_function_name" {
        description = "A name for the azure function app defining the walkthrough module and how it will be identified within your Azure subscription and resource group."
        type        = string
    }
    variable "azure_function_name_prefix" {
        description = "A prefix for the azure function name."
        type        = string
    }
    variable "resource_group" {
        description = "The name of the resource group in which to create the function app."
        type        = string
    }
    variable "resource_group_location" {
        description = "The location of the resource group where the function app will live."
        type        = string
    }
    variable "app_service_plan_id" {
        description = "The ID of the service plan where the azure function app will be hosted."
        type        = string
    }
    variable "storage_connection_string" {
        description = "This is the storage account used to inflate the ephemeral state of the Azure Function."
        type        = string
    }
    ```

1. Open the main.tf file and paste the the following:

    ```json
    // This resource block references all the inputs defined in the variables.tf file
    resource "azurerm_function_app" "walkthrough" {
        name                      = format("%s-%s", var.azure_function_name_prefix, lower(var.azure_function_name))
        resource_group_name       = var.resource_group
        location                  = var.resource_group_location
        app_service_plan_id       = var.app_service_plan_id
        storage_connection_string = var.storage_connection_string
        app_settings = {
            "environment" = "az-walkthrough-dev"
        }
    }
    ```

1. Open the output.tf and paste the following:

    ```json
    // This configures Terraform to display the module's output during the `terraform plan` and `terraform apply` steps.
    output "azure_function_id" {
        description = "The URLs of the app services created."
        value       = azurerm_function_app.walkthrough.id
    }
    output "azure_function_url" {
        description = "The resource ids of the app services created."
        value       = azurerm_function_app.walkthrough.default_hostname
    }
    output "app_service_type" {
        description = "The type of app service created."
        value       = azurerm_function_app.walkthrough.kind
    }
    ```

1. Prevent giving the azure function autoscale settings by navigating to the service-plan module and adding the following line if it's not already there:

    ```json
    # Navigate to the service-plan module
    cd ./infra/modules/providers/azure/service-plan
    # Add this line under the location property of the azurerm_monitor_autoscale_setting resource within the main.tf
    count = var.service_plan_tier == "Dynamic" ? 0 : 1
    ```

### **Step 5:** Implement Azure Walkthrough CIT

Let's implement the Azure Walkthrough CIT by declaring our new Walkthrough Module along with the modules that it depends on.

1. Navigate to the infra templates directory (i.e. ./infra/templates) and execute the following commands to wire up your new CIT:

    ```bash
    # Create a directory called "az-walkthrough-cit"
    mkdir -p ./az-walkthrough-cit
    # Navigate to that directory
    cd az-walkthrough-cit
    # Copy generic files
    cp ./../az-hello-world/backend.tf backend.tf
    cp ./../az-hello-world/versions.tf versions.tf
    # Create a commons.tf, main.tf, variables.tf, outputs.tf and terraform.tfvars
    touch variables.tf && touch commons.tf && touch main.tf && touch outputs.tf && touch terraform.tfvars
    ```

1. Open the terraform.tfvars file and paste the the following:

    ```json
    resource_group_location = "eastus"
    name                    = "az-hw-scratch"
    randomization_level     = 8
    ```

1. Open the variables.tf file and paste the the following:

    ```json
    // ---- General Configuration ----

    variable "name" {
        description = "An identifier used to construct the names of all resources in this template."
        type        = string
    }

    variable "randomization_level" {
        description = "Number of additional random characters to include in resource names to insulate against unexpected resource name collisions."
        type        = number
        default     = 8
    }

    variable "resource_group_location" {
        description = "The Azure region where all resources in this template should be created."
        type        = string
    }

    // ---- Storage Account Configuration ----
    variable "storage_account_tier" {
        description = "Determines the level of performance required."
        type = string
        default = "Standard"
    }

    variable "storage_account_replication" {
        description = "Defines the type of replication to use for this storage account. Valid options are LRS*, GRS, RAGRS and ZRS."
        type = string
        default = "LRS"
    }

    variable "storage_account_tags" {
        description = "Metadata about the storage account created."
        type = string
        default = "az-walkthrough-dev"
    }

    // ---- Service Plan Module Configuration ----
    variable "service_plan_tier" {
        description = "The tier under which the service plan is created. Details can be found at https://docs.microsoft.com/en-us/azure/app-service/overview-hosting-plans."
        type = string
        default = "Dynamic"
    }

    variable "service_plan_size" {
        description = "The compute and storage needed for the service plan to be deployed. Details can be found at https://azure.microsoft.com/en-us/pricing/details/app-service/windows/"
        type = string
        default = "Y1"
    }

    variable "service_plan_kind" {
        description = "The kind of Service Plan to be created. i.e. FunctionApp"
        type = string
        default = "FunctionApp"
    }
    ```

1. Open the commons.tf file and paste the the following:

    ```json
    module "provider" {
        source = "../../modules/providers/azure/provider"
    }

    resource "random_string" "workspace_scope" {
        keepers = {
            # Generate a new id each time we switch to a new workspace or app id
            ws_name = replace(trimspace(lower(terraform.workspace)), "_", "-")
            app_id  = replace(trimspace(lower(var.name)), "_", "-")
        }

        length  = max(1, var.randomization_level) // error for zero-length
        special = false
        upper   = false
    }

    locals {
        // sanitize names
        app_id  = random_string.workspace_scope.keepers.app_id
        region  = replace(trimspace(lower(var.resource_group_location)), "_", "-")
        ws_name = random_string.workspace_scope.keepers.ws_name
        suffix  = var.randomization_level > 0 ? "-${random_string.workspace_scope.result}" : ""

        // base name for resources, name constraints documented here: https://docs.microsoft.com/en-us/azure/architecture/best-practices/naming-conventions
        base_name    = length(local.app_id) > 0 ? "${local.ws_name}${local.suffix}-${local.app_id}" : "${local.ws_name}${local.suffix}"
        base_name_21 = length(local.base_name) < 22 ? local.base_name : "${substr(local.base_name, 0, 21 - length(local.suffix))}${local.suffix}"
        base_name_46 = length(local.base_name) < 47 ? local.base_name : "${substr(local.base_name, 0, 46 - length(local.suffix))}${local.suffix}"
        base_name_60 = length(local.base_name) < 61 ? local.base_name : "${substr(local.base_name, 0, 60 - length(local.suffix))}${local.suffix}"
        base_name_76 = length(local.base_name) < 77 ? local.base_name : "${substr(local.base_name, 0, 76 - length(local.suffix))}${local.suffix}"
        base_name_83 = length(local.base_name) < 84 ? local.base_name : "${substr(local.base_name, 0, 83 - length(local.suffix))}${local.suffix}"

        // Resolved resource names
        app_rg_name         = "${local.base_name_83}-app-rg" // app resource group (max 90 chars)
        sp_name             = "${local.base_name}-sp"        // service plan
        app_svc_name_prefix = local.base_name_21
        stor_account_prefix = local.base_name_21
    }
    ```

1. Open the main.tf file and paste the the following:

    ```json
    resource "azurerm_resource_group" "main" {
        name     = local.app_rg_name
        location = local.region
    }

    resource "azurerm_storage_account" "walkthrough" {
        name                     = format("%s%s", replace(lower(local.stor_account_prefix), "-", ""), "cob")
        resource_group_name      = azurerm_resource_group.main.name
        location                 = azurerm_resource_group.main.location
        account_tier             = var.storage_account_tier
        account_replication_type = var.storage_account_replication

        tags = {
            environment = var.storage_account_tags
        }
    }

    module "service_plan" {
        source                = "../../modules/providers/azure/service-plan"
        resource_group_name   = azurerm_resource_group.main.name
        service_plan_name     = local.sp_name
        service_plan_tier     = var.service_plan_tier
        service_plan_size     = var.service_plan_size
        service_plan_kind     = var.service_plan_kind
        service_plan_reserved = false
    }

    module "azure_function_walkthrough_app" {
        source                      = "../../modules/providers/azure/walkthrough-module"
        azure_function_name         = "azfun-wlkthrgh"
        azure_function_name_prefix  = local.app_svc_name_prefix
        resource_group              = azurerm_resource_group.main.name
        resource_group_location     = azurerm_resource_group.main.location
        app_service_plan_id         = module.service_plan.app_service_plan_id
        storage_connection_string   = azurerm_storage_account.walkthrough.primary_connection_string
    }
    ```

1. Open the outputs.tf file and paste the the following:

    ```json
    output "azure_function_app_id" {
        value = module.function_app.azure_function_id
    }

    output "azure_function_default_hostname" {
        value = module.function_app.azure_function_url
    }

    output "azure_function_app_service_type" {
        value = module.function_app.app_service_type
    }
    ```

### **Final Step:** Run Your New Template

| **walkthrough-module** | **az-walkthrough-cit** |
|----------|--------------|
| ![image](https://user-images.githubusercontent.com/10041279/73129957-02fd3300-3fb5-11ea-9d76-3923af50aa53.png) | ![image](https://user-images.githubusercontent.com/10041279/73129988-a9e1cf00-3fb5-11ea-9831-125edf62b18e.png) |

1. **Setup Local Environment Variables**

    * See step 3 of the quick start guide for guidance on how to setup your environment variables.

1. **Initialize a Terraform Remote Workspace**

    * Navigate to the az-walkthrough-cit directory (i.e. ./infra/templates/az-walkthrough-cit) and execute the following commands to set up your remote Terraform workspace.

    ```bash
    # This command initializes any modules referenced in your CIT. If new module references are added to your CIT or a module definition changes, rerun this command.
    terraform init -backend-config "storage_account_name=${TF_VAR_remote_state_account}" -backend-config "container_name=${TF_VAR_remote_state_container}"

    # This command configures Terraform to use a workspace unique to you.
    # This allows you to work without stepping over your teammate's deployments.
    terraform workspace new "az-walkthrough-dev-$USER" || terraform workspace select "az-walkthrough-dev-$USER"
    ```

    > **IMPORTANT!** Setting up your own Terraform dev workspace is critically important. It's a strong step towards shielding other deployed environments from any of the Terraform commands you will run hereafter. Always check your workspace before running 'terraform apply'.

1. **From the az-walkthrough-cit directory, execute the following commands to run the template and orchestrate a deployment.**

    ```bash
    # Ensure that the current workspace is az-walkthrough-dev-$USER.
    terraform workspace show

    # See what terraform will try to deploy without actually deploying.
    terraform plan

    # Run az-walkthrough-cit to execute a deployment.
    terraform apply -auto-approve

    # Preview newly resolved output of the deployed infrastructure
    terraform output -json
    ```

1. **Validate Infrastructure Deployed Successfully**

    * Login to the Azure Portal.
    * Search for "Resource Group" to find the Resource Group menu.
    * Find and Select the name of the Resource Group created from running the Azure Walkthrough CIT.
    * Select the App Service created from running the template.
    * Select the "overview" tab.
    * Wait for the App Service "URL" link to display itself from within the menu and then visit the link.

        <image src="https://user-images.githubusercontent.com/10041279/67352169-df899e80-f514-11e9-904a-fe31b91d1ccb.png" width="460"/>

## Experiencing errors?

If you're having trouble, the below documented errors may save you some time and get you back on track.

* **General error**:

    ```bash
    $ tree cobalt
    ├───...
    ├───.env.template
    ├───.env
    └───infra
        └───templates
            ├───az-walkthrough-cit
            └───.terraform # This is generated from running 'terraform init'. It holds a reference to your workspace, infrastructure state and backend.
    ```

There's a broad range of errors that can be solved simply be deleting the above .terraform directory. Once deleted, re-run terraform init and it's sub-sequent demands from within the same directory.

## Conclusion

Using the guidance from this walkthrough, you were able to deploy infrastructure by running a CIT that you built yourself. Additionally, if you completed the Cobalt [Quickstart Guide](./2_QUICK_START_GUIDE.md), you also deployed infrastructure by running our [*Azure Walkthrough CIT*](../infra/templates/az-walkthrough-cit/README.md "Azure Walkthrough CIT - Cobalt Infrastructure Template"). Both of these deployments were designed in way that would give you a basic understanding of the Cobalt Developer Workflow (i.e. create/choose a template ---> init ---> select workspace ---> plan ---> apply ---> destroy) that you can build on. This is why we'd like to point out that these two deployments did not include automated testing. Moving forward, however, we strongly encourage automated testing as a major part of your Cobalt Developer Workflow, SDLC and Cobalt [OSS contributions](https://opensource.microsoft.com/codeofconduct/faq/). Please continue to the recommended next step for guidance on automated testing in Cobalt.

### **Recommended Next Step:** *[Testing Cobalt Templates](./4_TEMPLATE_TESTING.md).*
