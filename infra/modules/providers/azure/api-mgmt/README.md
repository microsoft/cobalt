# Module Azure API Management

Azure API Management is a turnkey solution for publishing APIs to external and internal customers. It quickly creates consistent and modern API gateways for existing back-end services hosted anywhere.

More information for Azure API Management Service can be found [here](https://azure.microsoft.com/en-us/services/api-management)

A terraform module in Cobalt to provide API manangement with the following characteristics:

- Ability to specify resource group name in which the Service Plan is deployed.
- Ability to specify resource group location in which the Service Plan is deployed.
- Also gives ability to specify the following for API Manager based on the requirements:
  - name : The name of the API Manager to be deployed.
  - service_plan_resource_group_name : The Name of the Resource Group where the Service Plan exists.
  - publisher_name : The name of the Publisher/Company of the API Management Service.
  - publisher_email : The email of Publisher/Company of the API Management Service.
  - tags : A mapping of tags assigned to the resource.
  - sku_name : Specifies the plan's pricing tier.
  - capacity : Specifies the number of units associated with this API Management service.

Please click the [link](https://www.terraform.io/docs/providers/azurerm/d/api_management.html) to get additional details on settings in Terraform for Azure API Management.

## Usage

```
data "azurerm_resource_group" "apimgmt" {
  name      = "${var.service_plan_resource_group_name}"
}

resource "azurerm_api_management" "apimgmt" {
  name                = "${var.apimgmt_name}"
  location            = "${data.azurerm_resource_group.apimgmt.location}"
  resource_group_name = "${data.azurerm_resource_group.apimgmt.name}"
  publisher_name      = "${var.apimgmt_pub_name}"
  publisher_email     = "${var.apimgmt_pub_email}"
  tags                = "${var.resource_tags}"

  sku {
    name     = "${var.apimgmt_sku}"
    capacity = "${var.apimgmt_capacity}"
  }
}

Example Usage:

module "api_management" {
  service_plan_resource_group_name     = "${azurerm_resource_group.cluster_rg.name}"
  apimgmt_name                         = "testApiManager"
}
```
