## Azure App Service

Build, deploy, and scale enterprise-grade web, mobile, and API apps running on any platform. Meet rigorous performance, scalability, security and compliance requirements while using a fully managed platform to perform infrastructure maintenance.

More information for Azure App Services can be found [here](https://azure.microsoft.com/en-us/services/app-service/)

Cobalt gives ability to specify following settings for App Service based on the requirements:
- name : The name of the App Service.
- resource_group_name : The Name of the Resource Group where the App Service exists.
- location : The Azure location where the App Service exists.
- app_service_plan_id : The ID of the App Service Plan within which the App Service exists.
- tags : A mapping of tags to assign to the resource.

Please click the [link](https://www.terraform.io/docs/providers/azurerm/d/app_service.html) to get additional details on settings in Terraform for Azure App Service.

## Usage

```
variable "name" {
  default = "prod"
}

variable "location" {
  default = "eastus"
}

resource "azurerm_app_service" "appsvc" {
  name                = "${var.app_service_name}"
  location            = "${azurerm_resource_group.appsvc.location}"
  resource_group_name = "${azurerm_resource_group.appsvc.name}"
  app_service_plan_id = "${var.app_service_plan_id}"
  tags                = "${var.resource_tags}"
}
```
