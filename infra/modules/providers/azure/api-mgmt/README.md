# Module Azure API Management

Azure API Management is a turnkey solution for publishing APIs to external and internal customers. It quickly creates consistent and modern API gateways for existing back-end services hosted anywhere.

More information for Azure API Management Service can be found [here](https://azure.microsoft.com/en-us/services/api-management)

A terraform module in Cobalt to provide API manangement with the following characteristics:

- Ability to specify resource group name in which the Service Plan is deployed.
- Ability to specify resource group location in which the Service Plan is deployed.
- Also gives ability to specify the following for API Manager based on the requirements:
  - name : The name of the API Manager to be deployed.
  - service_plan_resource_group_name : The Name of the Resource Group where the Service Plan exists.
  - virtual_network_type : Virtual Network type of the vnet in which api management service needs to be created. Valid values are None, External, Internal.
  - subnet_resource_id : Subnet resource ID of the vnet in which api management service needs to be created.
  - publisher_name : The name of the Publisher/Company of the API Management Service.
  - publisher_email : The email of Publisher/Company of the API Management Service.
  - sku_name : Specifies the plan's pricing tier.
  - capacity : Specifies the number of units associated with this API Management service.
  - hostnameConfigurations : Custom hostname configuration of the API Management service.
    - type : Hostname type. Valid values are "Proxy", "Portal", "Management", "Scm", "DeveloperPortal".
    - hostName : Hostname to configure on the Api Management service.
    - encodedCertificate : Base64 Encoded certificate.
  - api_name : Name of the API's to be created for each app service.
  - display_name : The display name of the API.
  - service_url : The list of Absolute URL's of the backend service implementing this API.
  - apimgmt_logger_name : Logger name for API management.
  - appinsghts_instrumentation_key : Instrumentation key for App Insights.
  - api_operation_name : Name of the api management API operation to create.
  - api_operation_display_name : The Display Name for this API Management Operation.
  - api_operation_method : The HTTP Method used for this API Management Operation, like GET, DELETE, PUT or POST - but not limited to these values.

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
  operation_id                     = "${var.api_operation_name}"
  api_operation_display_name       = "${var.api_operation_display_name}"
  method                           = "${var.api_operation_method}"  
}
```

## Output

Once the deployments are completed successfully, the output for the current module will be in the format mentioned below:

```
Outputs:

api_url = [
    /subscriptions/xxxxf239-caxx-xxbf-b2xx-xxxxxx08965a/resourceGroups/test-rg/providers/Microsoft.ApiManagement/service/test-apimgmt/apis/test-api-0,
    /subscriptions/xxxxf239-caxx-xxbf-b2xx-xxxxxx08965a/resourceGroups/test-rg/providers/Microsoft.ApiManagement/service/test-apimgmt/apis/test-api-1
]
gatewayurl = /subscriptions/xxxxf239-caxx-xxbf-b2xx-xxxxxx08965a/resourceGroups/test-rg/providers/Microsoft.ApiManagement/service/test-apimgmt
```
