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

```
data "azurerm_resource_group" "appinsights" {
  name      = "${var.service_plan_resource_group_name}"
}

resource "azurerm_application_insights" "appinsights" {
  name                = "${var.appinsights_name}"
  resource_group_name = "${data.azurerm_resource_group.appinsights.name}"
  location            = "${data.azurerm_resource_group.appinsights.location}"
  application_type    = "${var.appinsights_application_type}"
  tags                = "${var.resource_tags}"
}

Example Usage:

module "app_insights" {
  service_plan_resource_group_name     = "${azurerm_resource_group.cluster_rg.name}"
  appinsights_name                     = "testAppInsights"
}
```
