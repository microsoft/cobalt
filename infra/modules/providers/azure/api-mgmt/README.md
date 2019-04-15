# Module Azure API Management

Azure API Management is a turnkey solution for publishing APIs to external and internal customers. It quickly creates consistent and modern API gateways for existing back-end services hosted anywhere.

A terraform module in Cobalt to provide API manangement with the following characteristics:

- Ability to specify resource group name in which the API manager is deployed.
- Ability to specify resource group location in which the API manager is deployed.
- Specify API manger name,type and capacity of API manager to deploy
- Can also specify SPI manager publisher name and email as part of the deployment

## Usage

```
variable "resource_group_name" {
  default = "cblt-apimgmt-rg"
}

variable "location" {
  default = "eastus"
}

resource "azurerm_resource_group" "apimgmt" {
  name     = "${var.resource_group_name}"
  location = "${var.location}"
}

resource "azurerm_api_management" "apimgmt" {
  name                = "${var.apimgmt_name}"
  location            = "${azurerm_resource_group.apimgmt.location}"
  resource_group_name = "${azurerm_resource_group.apimgmt.name}"
  publisher_name      = "${var.apimgmt_pub_name}"
  publisher_email     = "${var.apimgmt_pub_email}"

  sku {
    name     = "${var.apimgmt_sku}"
    capacity = "${var.apimgmt_capacity}"
  }
}

```