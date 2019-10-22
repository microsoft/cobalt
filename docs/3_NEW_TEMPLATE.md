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

| Cobalt Module | Cobalt Infrastructure Template Invoking a Module Instance |
|----------|----------|
| Azure service-plan | pending png |

The above table demonstrates in a clear way how *Cobalt Infrastructure Templates* reap the natural benefits of the reusability that's offered by *Cobalt Modules*. This is possible because Terraform modules grant *Cobalt modules* reusability as a feature. Let's experience what it's like to create your own *CIT* from scratch by following the below steps:

### **Step 1:** Model your planned infrastructure

For demonstration purposes, we have already modeled the infrastructure. You will build a *CIT* and title it **az-hello-world-from-scratch** within your codebase. This CIT when ran will create and deploy the Azure resources listed in the description of the below table.

| New CIT Name | Description | Deployment Goal |
|----------|----------|----------|
| **az-hello-world-from-scratch** | A Cobalt Infrastructue Template that when ran creates a basic [Azure Function App](https://docs.microsoft.com/en-us/azure/azure-functions/functions-overview) within an [App Service Plan](https://docs.microsoft.com/en-us/azure/app-service/overview-hosting-plans) accompanied with [Azure Storage](https://azure.microsoft.com/en-us/services/storage/blobs/). | <image src="https://user-images.githubusercontent.com/10041279/67136958-a9d27600-f1f3-11e9-896c-d18f3a287de5.png" width="400" height="200"/> |

Step 1 is complete!

### **Step 2:** Plan your modular strategy

Once you've modeled your planned infrastructure resources, we recommend answering the following questions:

1. > QUESTION: **"Which portion of my planned infrastructure do I want to roll-up into a reusable module?"**

    **ANSWER:** Currently, most Cobalt Modules are scoped to a very specific cloud infrastructure resource. In other words, modules encapsulate a configuration that targets a providers very specific cloud service product. The Azure Function Module we are creating will follow this pattern.

1. > QUESTION: **"Does Cobalt have existing reusuable modules configured for any portion of my planned infrastructure?"**

    **ANSWER:** At the time of this walkthrough, there are reusable modules for an Azure App Service Plan and Azure Storage, so you will use those to build part of your *CIT*. However, there is no current *Cobalt Module* configured for deploying an Azure Function. So, yes, a new Cobalt Module needs to be created. Let's design one!

### **Step 3:** Design Your Terraform Based *Cobalt Module*s

The first step of designing a *Cobalt Module* involves defining a Terraform module's 3 primary elements: input variables, output variables and resources. This will be all done via Terraform's [HCL language](https://learn.hashicorp.com/terraform), a language that grants developers the ability to target multiple cloud providers. Documentation for the HCL language is partitioned by cloud provider. You will become very familiar with Terraform's cloud provider documentation as you learn to use and build your own modules and CITs.

1. Visit the below link for insight into how we are making the below design decisions for the Azure Function *Cobalt Module* in this walkthrough.

    * Terraform - [Azure ARM Provider - Azure Function](https://www.terraform.io/docs/providers/azurerm/r/function_app.html#example-usage-in-a-consumption-plan-)

1. Define your resources - Defined below are the resource blocks that will be implemented:

    | Resource | Description |
    |--------|-------------|
    | azurerm_function_app | According to the Terraform docs, this is the only resource unique to an Azure Function. This resource block will be declared at the module level. |
    | azurerm_app_service_plan | Template level resource that this module depends on. |
    | azurerm_storage_account | Template level resource that this module depends on. |
    | azurerm_resource_group | Template level resource that this module depends on. |

1. Define inputs - When a CIT instantiates a module, it will configure that module using it's exposed input variable names. These variables will pass values to the attributes of the resource blocks internal to the module. These inputs have also been defined below:

    | *azurerm_function_app* resource attribute | Scope | Required | Input Variable Name | Description |
    |--------|-------------|-------------|-----------|-----------|
    | name | Input | yes | `azure_function_name` | A name for the function app and how it will be identified within your Azure subscription. |
    | name | Input | yes | `azure_function_name_prefix` | A prefix name for appending unique values to the azure function name. |
    | resource_group_name | Input | yes | `resource_group` | Most Azure infrastructure lives in a resource group container of your choice. By making this an input, each module instance can have a different resouce group. |
    | location | Input | yes | `resource_group_location` | The geo-location here should derive from the geo-location that the resource group name lives in. |
    | app_service_plan_id  | Input | yes | `app_service_plan_id` | This input implies that the azure function resource will live within an app service plan. |
    | storage_connection_string | Input | yes | `storage_connection_string` | This is the storage account in which the ephemeral state for an Azure Function will be orchestrated when the endpoint is invoked. |
    | app_settings | Internal | no | `-` | { environment = "walkthrough dev" } - We will provide a hard-coded key-value pair as an example that does not require an input. Value will not be determined by a CIT. |

1. Define outputs - A module instance will only output values that it's been pre-configured to output. It's **best practice** to configure module instance outputs so that you can validate expected results. These results are visible in standard out if passed to the template when running the terraform plan and apply steps. These outputs are defined below:

    | *azurerm_function_app* attribute | Scope | Required | Output Variable Name | Description |
    |--------|-------------|-------------|-----------|-----------|
    | id | Output | no | `azure_function_id` | This is the ID output by the function app and used within your Azure subscription. |
    | default_hostname | Output | no | `azure_function_url` | This is the url endpoint output by the Azure Function app. |
    | kind | Output | no | `app_service_type` | This should output "functionapp". |

    > NOTE: In this case, no attributes are required because no other resources in the CIT will depend on the output of the module instance.

### **Step 4:** Implement Your Terraform Based *Cobalt Module*s

Let's implement the Azure Function Cobalt Module and integrate the input variables, output variables and resources defined in the previous step.

1. Navigate to the azure providers directory (i.e. ./infra/modules/providers/azure) and execute the following commands to wire up your new module.

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
        resource_group_name       = var.resource_group_name
        location                  = var.resource_group_location
        app_service_plan_id       = var.app_service_plan_id
        storage_connection_string = var.storage_connection_string
        app_settings = {
            "environment" = "walkthrough dev"
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

1. Navigate to the infra templates directory (i.e. ./infra/templates) and execute the following commands to wire up your new CIT.

    ```bash
    # Create a directory called "function-app"
    mkdir -p ./az-hello-world-from-scratch
    # Navigate to that directory
    cd az-hello-world-from-scratch
    # Copy generic files
    cp ./../az-hello-world/backend.tf backend.tf
    cp ./../az-hello-world/versions.tf versions.tf
    # Create a commons.tf, main.tf, variables.tf and outputs.tf
    touch variables.tf
    touch commons.tf
    touch main.tf
    touch outputs.tf
    ```

1. Open the variables.tf file and paste the the following:

    ```HCL
    adf
    ```

1. Open the commons.tf file and paste the the following:

    ```HCL
    afd
    ```

1. Open the main.tf file and paste the the following:

```HCL
```

1. Open the outputs.tf file and paste the the following:

```HCL
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
