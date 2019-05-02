# Azure Application Insights

Application Insights is an extensible Application Performance Management (APM) service for web developers on multiple platforms. Use it to monitor your live web application. It will automatically detect performance anomalies. It includes powerful analytics tools to help you diagnose issues and to understand what users actually do with your app.

More information for Azure Application Insights can be found [here](https://docs.microsoft.com/en-us/azure/azure-monitor/app/app-insights-overview)

A terraform module in Cobalt to provide Application Insights with the following characteristics:

- Ability to deploy Application Insights in the same resource group as the Service Plan.
- Ability to deploy Application Insights in the same resource group location in which the Service Plan is deployed.
- Also gives ability to specify the following for Application Insights based on the requirements:
  - name : Specifies the name of the Application Insights component. Changing this forces a new resource to be created.
  - application_type : Specifies the type of Application Insights to create. Valid values are ios for iOS, java for Java web, MobileCenter for App Center, Node.JS for Node.js, other for General, phone for Windows Phone, store for Windows Store and web for ASP.NET. Please note these values are case sensitive; unmatched values are treated as ASP.NET by Azure. Changing this forces a new resource to be created.
  - tags : A mapping of tags to assign to the resource.

Please click the [link](https://www.terraform.io/docs/providers/azurerm/r/application_insights.html) to get additional details on settings in Terraform for Azure Application Insights.

## Usage

### Module Definitions

- Service Plan Module : infra/modules/providers/azure/service-plan
- App Insights Module : infra/modules/providers/azure/app-insights

```
variable "resource_group_name" {
  value = "test-rg"
}

variable "service_plan_name" {
  value = "test-svcplan"
}

variable "appinsights_name" {
  value = "test-app-insights"
}

module "service_plan" {
  resource_group_name     = "${var.resource_group_name}"
  resource_group_location = "${var.resource_group_location}"
  service_plan_name       = "${var.service_plan_name}"
}

module "app_insights" {
  service_plan_resource_group_name     = "${var.resource_group_name}"
  appinsights_name                     = "${var.appinsights_name}"
}
```

## Output

Once the deployments are completed successfully, the output for the current module will be in the format mentioned below:

```
Outputs:

app_insights_app_id = 11d75ba9-f5b8-4694-9381-13cc0d400f81
app_insights_instrumentation_key = c2d75785-6c5f-425f-9880-6036694c93cd
```
