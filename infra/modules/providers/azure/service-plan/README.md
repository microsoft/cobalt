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

```
variable "name" {
  default = "prod"
}

variable "location" {
  default = "eastus"
}

resource "azurerm_resource_group" "svcplan" {
  name     = "${var.resource_group_name}"
  location = "${var.resource_group_location}"
  tags     = "${var.resource_tags}"
}

resource "azurerm_app_service_plan" "svcplan" {
  name                = "${var.service_plan_name}"
  location            = "${azurerm_resource_group.svcplan.location}"
  resource_group_name = "${azurerm_resource_group.svcplan.name}"
  kind                = "${var.service_plan_kind}"
  tags                = "${var.resource_tags}"
  reserved            = "${var.service_plan_kind == "Linux" ? true : "${var.service_plan_reserved}"}"

  sku {
    tier      = "${var.service_plan_tier}"
    size      = "${var.service_plan_size}"
    capacity  = "${var.service_plan_capacity}"
  }
}
```
