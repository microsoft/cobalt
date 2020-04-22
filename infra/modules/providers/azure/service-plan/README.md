# Module Azure App Service Plan

In App Service, an app runs in an App Service plan. An App Service plan defines a set of compute resources for a web app to run. These compute resources are analogous to the server farm in conventional web hosting. One or more apps can be configured to run on the same computing resources.

This is a terraform module in Cobalt to provide an App Service Plan with the following characteristics:

- Ability to specify resource group name in which the App Service Plan is deployed.
- Ability to specify resource group location in which the App Service Plan is deployed.
- Also gives ability to specify following settings for App Service Plan based on the requirements:
  - kind : The kind of the App Service Plan to create.
  - tags : A mapping of tags to assign to the resource.
  - reserved : Is this App Service Plan Reserved.
  - tier : Specifies the plan's pricing tier. Additional details can be found at this [link](https://docs.microsoft.com/en-us/azure/app-service/overview-hosting-plans)
  - size : Specifies the plan's instance size.
  - capacity : Specifies the number of workers associated with this App Service Plan.

Please click the [link](https://www.terraform.io/docs/providers/azurerm/r/app_service_plan.html#capacity) to get additional details on settings in Terraform for Azure App Service Plan.

## Usage

### Module Definition

Service Plan Module : infra/modules/providers/azure/service-plan

```
variable "resource_group_name" {
  value = "test-rg"
}

variable "resource_group_location" {
  value = "eastus"
}

variable "service_plan_name" {
  value = "test-svcplan"
}

module "service_plan" {
  source              = "github.com/Microsoft/cobalt/infra/modules/providers/azure/service-plan"
  name                = "${var.service_plan_name}"
  location            = "${var.resource_group_location}"
  resource_group_name = "${var.resource_group_name}"
}
```
## Outputs

Once the deployments are completed successfully, the output for the current module will be in the format mentioned below:

```
Outputs:

resource_group_name = test-rg
service_plan_kind = linux
service_plan_name = test-svcplan
```