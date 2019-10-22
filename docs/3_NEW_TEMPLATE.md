# 3. Cobalt Templating From Scratch

## 3.1 Overview

Per the [quickstart guide](./2_QUICK_START_GUIDE.md), we demonstrated that you can get pretty far with *Cobalt* by simply relying on any out of the box *Cobalt Infrastructure Template* or *CIT* (/kɪt/). However, for several reasons, you may very well have unique infrastructure scenarios that require you to extract more use out of *Cobalt*. Therefore, we recommend building a *Cobalt Infrastructure Template* from scratch in order to cultivate a deeper understanding of what *Cobalt* has to offer.

A major core feature of *Cobalt* is that it offers a library of Terraform based *Cobalt Module*s that allow you to create and build-up *CIT*s. The act of creating a *CIT* from scratch will always involve thoughtfully choosing a mix of *Cobalt Module*s that already exist or were created by you. This section of the walkthrough will be an exercise in building *CIT*s for Cobalt. Happy templating! 😄

> *Have you completed the quickstart guide? Deploy your first infrastructure as code project with Cobalt by following the [quickstart guide](./2_QUICK_START_GUIDE.md).*

## 3.2 Goals and Objectives

🔲 Demonstrate how to create *Cobalt Modules* and *CIT*s that work for your custom infrastructure scenario.

🔲 Improve your understanding of how to use existing *Cobalt Module*s and *CIT*s so that they can better work for you.

🔲 Feel confident in moving forward to our next recommended section: *[Testing Cobalt Templates](./4_TEMPLATE_TESTING.md).*

## 3.3 Prerequisites

| Prereqs | Description |
|----------|--------------|
| [Quickstart Guide](./2_QUICK_START_GUIDE.md) | The quickstart guide provides all of the prerequisites you'll need to create your own *CIT* and run it.|
| [Terraform Modules](https://www.terraform.io/docs/configuration/modules.html) | An introductory understanding of Terraform modules.|

## 3.4 Walkthrough - Create a New Template

*Cobalt Module*s primarily rely on [Terraform Modules](https://www.terraform.io/docs/configuration/modules.html). The primary purpose of a Terraform Module as a feature is to encapsulate parts of your potential infrastructure configuration into reusable units. CIT's instantiate modules. Here's a great example of Cobalt's existing [Azure service-plan](./../infra/modules/providers/azure/service-plan/README.md) module. It's being reused by several out of the box CIT's.

| Cobalt Infrastructure Template | CIT Instantiating an [Azure service-plan](./../infra/modules/providers/azure/service-plan/README.md) Module |
|----------|----------|
|[az-hello-world](./../infra/templates/az-hello-world/README.md)| ![image](https://user-images.githubusercontent.com/10041279/67301762-82123500-f4b5-11e9-9bff-8dc07a4fe001.png) |
|[az-service-single-region](./../infra/templates/az-hello-world/README.md)| ![image](https://user-images.githubusercontent.com/10041279/67302608-bf2af700-f4b6-11e9-9add-846bd2df42be.png) |
|[az-isolated-service-single-region](./../infra/templates/az-hello-world/README.md)| ![image](https://user-images.githubusercontent.com/10041279/67302203-2ac09480-f4b6-11e9-839f-19d40abd51ae.png) |

The above table demonstrates in a clear way how *Cobalt Infrastructure Templates* reap the natural benefits of the reusability that's offered by *Cobalt Modules*. This is possible because Terraform modules grant *Cobalt modules* reusability as a feature. Let's experience what it's like to create your own *CIT* from scratch by following the below steps:

### **Step 1:** Model your planned infrastructure

For demonstration purposes, we have already modeled the infrastructure. You will build a *CIT* and title it **az-hello-world-from-scratch** within your codebase. This CIT when ran will create and deploy the Azure resources listed in the description of the below table.

| New CIT Name | Description | Deployment Goal |
|----------|----------|----------|
| **az-hello-world-from-scratch** | A Cobalt Infrastructue Template that when ran creates a basic [Azure Function App](https://docs.microsoft.com/en-us/azure/azure-functions/functions-overview) within an [App Service Plan](https://docs.microsoft.com/en-us/azure/app-service/overview-hosting-plans) accompanied with [Azure Storage](https://azure.microsoft.com/en-us/services/storage/blobs/). | <image src="https://user-images.githubusercontent.com/10041279/67136958-a9d27600-f1f3-11e9-896c-d18f3a287de5.png" width="500" height="200"/> |

Step 1 is complete!

### **Step 2:** Plan your modular strategy

Once you've modeled your planned infrastructure resources, we recommend answering the following questions:

1. > QUESTION: **"Which portion of my planned infrastructure do I want to roll-up into a reusable module?"**

    **ANSWER:** Currently, most Cobalt Modules are scoped to a very specific cloud infrastructure resource. In other words, modules encapsulate a configuration that targets a providers very specific cloud service product. The Azure Function Module we are creating will follow this pattern.

1. > QUESTION: **"Does Cobalt have existing reusuable modules configured for any portion of my planned infrastructure?"**

    **ANSWER:** At the time of this walkthrough, there are reusable modules for an Azure App Service Plan and Azure Storage, so you will use those to build part of your *CIT*. However, there is no current *Cobalt Module* configured for deploying an Azure Function. So, yes, a new Cobalt Module needs to be created. Let's design one!

Step 2 is complete!

### **Step 3:** Design Your Terraform Based *Cobalt Module*s

The first step of designing a *Cobalt Module* involves defining a Terraform module's 3 primary elements: input variables, output variables and resources. This will be all done via Terraform's [HCL language](https://learn.hashicorp.com/terraform), a language that grants developers the ability to target multiple cloud providers. Documentation for the HCL language is partitioned by cloud provider. You will become very familiar with Terraform's cloud provider documentation as you learn to use and build your own modules and CITs.

1. Visit the below link for insight into how we are making the below design decisions for the Azure Function *Cobalt Module* in this walkthrough.

    * Terraform - [Azure ARM Provider - Azure Function](https://www.terraform.io/docs/providers/azurerm/r/function_app.html#example-usage-in-a-consumption-plan-)

1. Define your resources - Defined below are the resource blocks that will be implemented:

    | Resource | Description |
    |--------|-------------|
    | azurerm_function_app | According to the Terraform docs, this is the only resource unique to an Azure Function. This resource block will be declared within the module. |
    | azurerm_app_service_plan | The azure function app needs to live within an app service plan so we have to instantiate the existing module that encapsulates the app service plan. |
    | azurerm_storage_account | The azure function app's ephemeral state needs a dedicated storage account, however, after further inspection, the existing module for the storage account will not be usuable as it does not support a connection string as an output due to security best practices. We'll have to declare the azurerm_storage_account resource directly from the template and avoid using it's module.  |
    | azurerm_resource_group | Most Azure infrastructure lives in a resource group container so this will be a part of the configuration as well.  |

1. Define inputs - When a CIT instantiates a module, it will configure that module using it's exposed input variable names. These variables will pass values to the attributes of the resource blocks internal to the module. These inputs have also been defined for you below:

    | *azurerm_function_app* resource attribute | Scope | Required | Input Variable Name | Description |
    |--------|-------------|-------------|-----------|-----------|
    | name | Input | yes | `azure_function_name` | A name for the function app and how it will be identified within your Azure subscription. |
    | name | Input | yes | `azure_function_name_prefix` | A prefix name for appending unique values to the azure function name. |
    | resource_group_name | Input | yes | `resource_group` | Most Azure infrastructure lives in a resource group container of your choice. By making this an input, each module instance can have a different resouce group. |
    | location | Input | yes | `resource_group_location` | The geo-location here should derive from the geo-location that the resource group name lives in. |
    | app_service_plan_id  | Input | yes | `app_service_plan_id` | This input implies that the azure function resource will live within an app service plan. |
    | storage_connection_string | Input | yes | `storage_connection_string` | This is the storage account in which the ephemeral state for an Azure Function will be orchestrated when the endpoint is invoked. |
    | app_settings | Internal | no | `-` | { environment = "walkthrough dev" } - We will provide a hard-coded key-value pair as an example that does not require an input. Value will not be determined by a CIT. |

1. Define outputs - A module instance will only output values that it's been pre-configured to output. It's **best practice** to configure module instance outputs so that you can validate expected results. These results are visible in standard out if passed to the template when running the terraform plan and apply steps. These outputs are defined for you below:

    | *azurerm_function_app* attribute | Scope | Required | Output Variable Name | Description |
    |--------|-------------|-------------|-----------|-----------|
    | id | Output | no | `azure_function_id` | This is the ID output by the function app and used within your Azure subscription. |
    | default_hostname | Output | no | `azure_function_url` | This is the url endpoint output by the Azure Function app. |
    | kind | Output | no | `app_service_type` | This should output "functionapp". |

    > NOTE: In this case, no attributes are required because no other resources in the CIT will depend on the output of the module instance.

### **Step 4:** Implement Your Terraform Based *Cobalt Module*s

Let's implement the Azure Function Cobalt Module and integrate the input variables, output variables and resources defined in the previous step.

1. Navigate to the azure providers directory (i.e. ./infra/modules/providers/azure) and execute the following commands to wire up your new module:

    ```bash
    # Create a directory called "function-app"
    mkdir -p ./function-app
    # Navigate to that directory
    cd function-app
    # Create a main.tf, variables.tf and output.tf
    touch main.tf
    touch variables.tf
    touch output.tf
    ```

1. Open the variables.tf and paste the following:

    ```HCL
    //These are the inputs for your Azure Function Cobalt Module
    variable "azure_function_name" {
        description = "A name for the function app and how it will be identified within your Azure subscription and resource group."
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
        description = "This is the storage account where the ephemeral state for an Azure Function will be orchestrated when the endpoint is invoked."
        type        = string
    }
    ```

1. Open the main.tf file and paste the the following:

    ```HCL
    // This resource block references all the inputs defined in the variables.tf file
    resource "azurerm_function_app" "walkthrough" {
        name                      = format("%s-%s", var.azure_function_name_prefix, lower(var.azure_function_name))
        resource_group_name       = var.resource_group
        location                  = var.resource_group_location
        app_service_plan_id       = var.app_service_plan_id
        storage_connection_string = var.storage_connection_string
        app_settings = {
            "environment" = "hw-from-scratch"
        }
    }
    ```

1. Open the output.tf and paste the following:

    ```HCL
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

### **Step 5:** Implement Azure Hello World From Scratch CIT

Let's implement the Azure Hello World From Scratch CIT by instantiating our new Azure Function Cobalt Module along with the modules that it depends on.

1. Navigate to the infra templates directory (i.e. ./infra/templates) and execute the following commands to wire up your new CIT:

    ```bash
    # Create a directory called "function-app"
    mkdir -p ./az-hello-world-from-scratch
    # Navigate to that directory
    cd az-hello-world-from-scratch
    # Copy generic files
    cp ./../az-hello-world/backend.tf backend.tf
    cp ./../az-hello-world/versions.tf versions.tf
    # Create a commons.tf, main.tf, variables.tf, outputs.tf and terraform.tfvars
    touch variables.tf touch commons.tf touch main.tf touch outputs.tf touch terraform.tfvars
    ```

1. Open the terraform.tfvars file and paste the the following:

    ```HCL
    resource_group_location = "eastus"
    name                    = "az-hw-scratch"
    randomization_level     = 8
    ```

1. Open the variables.tf file and paste the the following:

    ```HCL
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
        default = "hw-from-scratch"
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

    ```HCL
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
        stor_account_prefix = local.base_name_46
    }
    ```

1. Open the main.tf file and paste the the following:

    ```HCL
        resource "azurerm_resource_group" "main" {
            name     = local.app_rg_name
            location = local.region
        }

        resource "azurerm_storage_account" "walkthrough" {
            name                     = format("%s%s", replace(lower(local.stor_account_prefix), "-", ""), "azfuncappsa")
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

        # This is a counter-example as connection string outputs are not best-practice.
        module "function_app" {
            source                      = "../../modules/providers/azure/function-app"
            azure_function_name         = "azfun-wlkthrgh"
            azure_function_name_prefix  = local.app_svc_name_prefix
            resource_group              = azurerm_resource_group.main.name
            resource_group_location     = azurerm_resource_group.main.location
            app_service_plan_id         = module.service_plan.app_service_plan_id
            storage_connection_string   = azurerm_storage_account.walkthrough.primary_connection_string
        }
    ```

1. Open the outputs.tf file and paste the the following:

    ```HCL
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

### **Step 6:** Run Your New Template

| Final **Azure Function Cobalt Module** | Final **az-hello-world-from-scratch** CIT |
|----------|--------------|
| pending | pending |

1. Setup Local Environment Variables


1. Initialize a Terraform Remote Workspace


1. Validate Infrastructure Deployed Successfully


### **Final Step:** Teardown Infrastructure Resources


## Conclusion

As both the CITs and the Cobalt Modules that they are composed of continue to grow and become more robust, we welcome your contributions. *[A Link to contribution guidelines](pending)*

### **Recommended Next Step:** *[Testing Cobalt Templates](./4_TEMPLATE_TESTING.md).*
