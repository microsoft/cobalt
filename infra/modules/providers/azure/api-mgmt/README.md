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

### Module Definitions

The API Manager is dependent on deployment of Service Plan and App Service. Make sure to deploy those modules before deploying the API Manager.

- Service Plan Module : infra/modules/providers/azure/service-plan
- App Service Module : infra/modules/providers/azure/app-service
- API Management Module : infra/modules/providers/azure/api-mgmt

```
variable "resource_group_name" {
  value = "test-rg"
}

variable "service_plan_name" {
  value = "test-svcplan"
}

variable "apimgmt_name" {
  value = "test-apimgr"
}

variable "api_name" {
  value = "test-api"
}

module "service_plan" {
  resource_group_name                 = "${var.resource_group_name}"
  resource_group_location             = "${var.resource_group_location}"
  service_plan_name                   = "${var.service_plan_name}"
}

module "api_management" {
  service_plan_resource_group_name     = "${module.service_plan.resource_group_name}"
  apimgmt_name                         = "${var.apimgmt_name}"
}
```
<!-- module "test_api" {
  api_name                         = "${var.api_name}"
} -->
