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

The API Manager is dependent on deployment of Service Plan, App Service and App Insights. Make sure to deploy those modules before deploying the API Manager.

- Service Plan Module : infra/modules/providers/azure/service-plan
- App Service Module : infra/modules/providers/azure/app-service
- App Insights Module : infra/modules/providers/azure/app-insights
- API Management Module : infra/modules/providers/azure/api-mgmt

```
variable "resource_group_name" {
  value = "test-rg"
}

variable "service_plan_name" {
  value = "test-svcplan"
}

variable "app_service_name" {
  value = {
    appservice1="DOCKER|<user1/image1:tag1>"
    appservice2="DOCKER|<user2/image2:tag2>"
  }
}

variable "appinsights_name" {
  value = "test-appinsights"
}

variable "apimgmt_name" {
  value = "test-apimgr"
}

variable "api_name" {
  value = "test-api"
}

module "service_plan" {
  source                  = "github.com/Microsoft/cobalt/infra/modules/providers/azure/service-plan"
  resource_group_name     = "${var.resource_group_name}"
  resource_group_location = "${var.resource_group_location}"
  service_plan_name       = "${var.service_plan_name}"
}

module "app_service" {
  source                              = "github.com/Microsoft/cobalt/infra/modules/providers/azure/app-service"
  service_plan_resource_group_name    = "${var.resource_group_name}"
  service_plan_name                   = "${var.service_plan_name}"
}

module "app_insights" {
  source                               = "github.com/Microsoft/cobalt/infra/modules/providers/azure/app-insights"
  service_plan_resource_group_name     = "${var.resource_group_name}"
  appinsights_name                     = "${var.appinsights_name}"
}

module "api_management" {
  source                           = "github.com/Microsoft/cobalt/infra/modules/providers/azure/api-mgmt"
  service_plan_resource_group_name = "${module.service_plan.resource_group_name}"
  apimgmt_name                     = "${var.apimgmt_name}"
  api_name                         = "${var.api_name}"
  service_url                      = "${module.app_service.outputs.app_service_uri}"
  apimgmt_logger_name              = ${var.apimgmt_logger_name}
  appinsghts_instrumentation_key   = "${module.app_insights.outputs.app_insights_instrumentation_key}"
}
```

## Output

Once the deployments are completed successfully, the output for the current module will be in the format mentioned below:

```
Outputs:

api_url = [
    /subscriptions/xxxxxxxx9-xx68-xxxf-xxf0-xxxxxxxxxa/resourceGroups/test-rg/providers/Microsoft.ApiManagement/service/test-apimgr/apis/test-api-0,
    /subscriptions/41f2f239-ca68-48bf-b2f0-dff8b108965a/resourceGroups/test-rg/providers/Microsoft.ApiManagement/service/test-apimgr/apis/test-api-1
]
management_api_url = https://test-apimgr.management.azure-api.net
scm_url = https://test-apimgr.scm.azure-api.net
```
