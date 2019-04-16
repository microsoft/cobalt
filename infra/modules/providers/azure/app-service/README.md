# Module Azure App Service

Build, deploy, and scale enterprise-grade web, mobile, and API apps running on any platform. Meet rigorous performance, scalability, security and compliance requirements while using a fully managed platform to perform infrastructure maintenance.

This is a terraform module in Cobalt to provide an App Service with the following characteristics:

- Ability to specify resource group name and location in which the App Service is deployed.
- Specify App Service Plan name, tier, size and kind of Service Plan.
- Also specify App Service name and the Service Plan details under which the service deploys.

## Usage

```
variable "resource_group_name" {
  default = "cblt-svcplan-rg"
}

variable "location" {
  default = "eastus"
}

rresource "azurerm_resource_group" "appsvc" {
  name     = "${var.resource_group_name}"
  location = "${var.resource_group_location}"
}

resource "azurerm_app_service_plan" "appsvc" {
  name                = "${var.svcplan_name}"
  location            = "${azurerm_resource_group.appsvc.location}"
  resource_group_name = "${azurerm_resource_group.appsvc.name}"
  kind                = "${var.svcplan_kind}"

  sku {
    tier = "${var.svcplan_tier}"
    size = "${var.svcplan_size}"
  }
}

resource "azurerm_app_service" "appsvc" {
  name                = "${var.appsvc_name}"
  location            = "${azurerm_resource_group.appsvc.location}"
  resource_group_name = "${azurerm_resource_group.appsvc.name}"
  app_service_plan_id = "${azurerm_app_service_plan.appsvc.id}"
}

```