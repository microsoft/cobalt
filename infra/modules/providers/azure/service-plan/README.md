# Module Azure App Service Plan

In App Service, an app runs in an App Service plan. An App Service plan defines a set of compute resources for a web app to run. These compute resources are analogous to the server farm in conventional web hosting. One or more apps can be configured to run on the same computing resources.

This is a terraform module in Cobalt to provide an App Service Plan with the following characteristics:

- Ability to specify resource group name in which the App Service Plan is deployed.
- Ability to specify resource group location in which the App Service Plan is deployed.
- Specify App Service Plan name, tier, size and kind of API manager to deploy
- Also specify App Service name and the Service Plan details under which the service deploys.

## Azure App Service

Build, deploy, and scale enterprise-grade web, mobile, and API apps running on any platform. Meet rigorous performance, scalability, security and compliance requirements while using a fully managed platform to perform infrastructure maintenance.

## Usage

```
variable "resource_group_name" {
  default = "cblt-svcplan-rg"
}

variable "location" {
  default = "eastus"
}

resource "azurerm_resource_group" "svcplan" {
  name     = "${var.resource_group_name}"
  location = "${var.resource_group_location}"
}

resource "azurerm_app_service_plan" "svcplan" {
  name                = "${var.svcplan_name}"
  location            = "${azurerm_resource_group.svcplan.location}"
  resource_group_name = "${azurerm_resource_group.svcplan.name}"
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
