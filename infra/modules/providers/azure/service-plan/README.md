# Module Azure App Service Plan

In App Service, an app runs in an App Service plan. An App Service plan defines a set of compute resources for a web app to run. These compute resources are analogous to the server farm in conventional web hosting. One or more apps can be configured to run on the same computing resources.

This is a terraform module in Cobalt to provide an App Service Plan with the following characteristics:

- Ability to specify resource group name in which the App Service Plan is deployed.
- If a name is not specified, it will generate a random id and add it as a prefix for the names of all the resources created.
- Ability to specify resource group location in which the App Service Plan is deployed.
- Also gives ability to specify following settings for App Service Plan based on the requirements:
  - kind : The kind of the App Service Plan to create.
  - tags : A mapping of tags to assign to the resource.
  - reserved : Is this App Service Plan Reserved.
  - tier : Specifies the plan's pricing tier. Additional details can be found at this [link](https://docs.microsoft.com/en-us/azure/app-service/overview-hosting-plans)
  - size : Specifies the plan's instance size.
  - capacity : Specifies the number of workers associated with this App Service Plan.

Please click the [link](https://www.terraform.io/docs/providers/azurerm/r/app_service_plan.html#capacity) to get additional details on settings in Terraform for Azure App Service Plan.

```
variable "name" {
  default = "prod"
}

variable "location" {
  default = "eastus"
}

resource "azurerm_resource_group" "svcplan" {
  name     = "${var.resource_group_name == "" ? "${local.name}-cobalt-rg" : "${var.resource_group_name}"}"
  location = "${var.resource_group_location}"
  tags     = "${merge(map("Name", "${local.name}"), var.resource_tags)}"
}

resource "azurerm_app_service_plan" "svcplan" {
  name                = "${var.svcplan_name == "" ? "${local.name}-cobalt-svcplan" : "${var.svcplan_name}"}"
  location            = "${azurerm_resource_group.svcplan.location}"
  resource_group_name = "${azurerm_resource_group.svcplan.name}"
  kind                = "${var.svcplan_kind}"
  tags                = "${merge(map("Name", "${local.name}"), var.resource_tags)}"
  reserved            = "${var.svcplan_kind == "Linux" ? true : "${var.svcplan_reserved}"}"

  sku {
    tier      = "${var.svcplan_tier}"
    size      = "${var.svcplan_size}"
    capacity  = "${var.svcplan_capacity}"
  }
}
```

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
  name                = "${var.appsvc_name == "" ? "${local.name}-cobalt-appsvc" : "${var.appsvc_name}"}"
  location            = "${azurerm_resource_group.svcplan.location}"
  resource_group_name = "${azurerm_resource_group.svcplan.name}"
  app_service_plan_id = "${azurerm_app_service_plan.svcplan.id}"
  tags                = "${merge(map("Name", "${local.name}"), var.resource_tags)}"
}
```

## Azure Public IP

Public IP addresses allow Internet resources to communicate inbound to Azure resources. Public IP addresses also enable Azure resources to communicate outbound to Internet and public-facing Azure services with an IP address assigned to the resource.

More information for Azure Public IP addresses can be found [here](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-ip-addresses-overview-arm)

Cobalt gives ability to specify following settings for Public IP based on the requirements:
- name : Specifies the name of the Public IP resource . Changing this forces a new resource to be created.
- resource_group_name : The name of the resource group in which to create the public ip.
- location : Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created.
- sku : The SKU of the Public IP. Accepted values are Basic and Standard. Defaults to Basic.
- allocation_method : Defines the allocation method for this IP address. Possible values are Static or Dynamic.
- tags : A mapping of tags to assign to the resource.

Please click the [link](https://www.terraform.io/docs/providers/azurerm/r/public_ip.html) to get additional details on settings in Terraform for Azure Public IP.

## Usage

```
variable "name" {
  default = "prod"
}

variable "location" {
  default = "eastus"
}

resource "azurerm_public_ip" "appsvc" {
  name                = "${var.publicip_name == "" ? "${local.name}-cobalt-publicip" : "${var.publicip_name}"}"
  resource_group_name = "${azurerm_resource_group.svcplan.name}"
  location            = "${azurerm_resource_group.svcplan.location}"
  sku                 = "${var.publicip_sku}"
  allocation_method   = "${var.pubip_alloc_method}"
  tags                = "${merge(map("Name", "${local.name}"), var.resource_tags)}"
}
```

## Azure Load Balancer

With Azure Load Balancer, you can scale your applications and create high availability for your services. Load Balancer supports inbound and outbound scenarios, provides low latency and high throughput, and scales up to millions of flows for all TCP and UDP applications.

More information for Azure load balancer can be found [here](https://docs.microsoft.com/en-us/azure/load-balancer/load-balancer-overview)

Cobalt gives ability to specify following settings for Load Balancer based on the requirements:
- name : Specifies the name of the Load Balancer.
- resource_group_name : The name of the Resource Group in which to create the Load Balancer.
- location : Specifies the supported Azure Region where the Load Balancer should be created.
- tags : A mapping of tags to assign to the resource.
- frontend_ip_configuration supports the following:
  - name : Specifies the name of the frontend ip configuration.
  - public_ip_address_id : Th ID of a Public IP Address which should be associated with the Load Balancer.

Please click the [link](https://www.terraform.io/docs/providers/azurerm/r/loadbalancer.html) to get additional details on settings in Terraform for Azure Load Balancer.

## Usage 

```
variable "name" {
  default = "prod"
}

variable "location" {
  default = "eastus"
}

resource "azurerm_lb" "appsvc" {
  name                = "${var.lb_name == "" ? "${local.name}-cobalt-loadbalancer" : "${var.lb_name}"}"
  location            = "${azurerm_resource_group.svcplan.location}"
  resource_group_name = "${azurerm_resource_group.svcplan.name}"
  tags                = "${merge(map("Name", "${local.name}"), var.resource_tags)}"

  frontend_ip_configuration {
    name                 = "${azurerm_public_ip.appsvc.name}"
    public_ip_address_id = "${azurerm_public_ip.appsvc.id}"
  }
}
```