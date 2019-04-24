# Module Azure API Management

Azure API Management is a turnkey solution for publishing APIs to external and internal customers. It quickly creates consistent and modern API gateways for existing back-end services hosted anywhere.

More information for Azure API Management Service can be found [here](https://azure.microsoft.com/en-us/services/api-management)

A terraform module in Cobalt to provide API manangement with the following characteristics:

- Ability to specify resource group name in which the API manager is deployed.
- Ability to specify resource group location in which the API manager is deployed.
- Also gives ability to specify the following for API Manager based on the requirements:
  - name : The name of the API Manager to be deployed.
  - publisher_name : The name of the Publisher/Company of the API Management Service.
  - publisher_email : The email of Publisher/Company of the API Management Service.
  - tags : A mapping of tags assigned to the resource.
  - sku_name : Specifies the plan's pricing tier.
  - capacity : Specifies the number of units associated with this API Management service.

Please click the [link](https://www.terraform.io/docs/providers/azurerm/d/api_management.html) to get additional details on settings in Terraform for Azure API Management.

## Usage

```
variable "resource_group_name" {
  default = "cblt-apimgmt-rg"
}

variable "resource_group_location" {
  default = "eastus"
}

resource "azurerm_resource_group" "apimgmt" {
  name     = "${var.resource_group_name}"
  location = "${var.resource_group_location}"
  tags     = "${var.resource_tags}"
}

resource "azurerm_api_management" "apimgmt" {
  name                = "${var.apimgmt_name}"
  location            = "${azurerm_resource_group.apimgmt.location}"
  resource_group_name = "${azurerm_resource_group.apimgmt.name}"
  publisher_name      = "${var.apimgmt_pub_name}"
  publisher_email     = "${var.apimgmt_pub_email}"
  tags                = "${var.resource_tags}"

  sku {
    name     = "${var.apimgmt_sku}"
    capacity = "${var.apimgmt_capacity}"
  }
}
```

# Azure Application Insights

Application Insights is an extensible Application Performance Management (APM) service for web developers on multiple platforms. Use it to monitor your live web application. It will automatically detect performance anomalies. It includes powerful analytics tools to help you diagnose issues and to understand what users actually do with your app.

More information for Azure Application Insights can be found [here](https://docs.microsoft.com/en-us/azure/azure-monitor/app/app-insights-overview)

A terraform module in Cobalt to provide Application Insights with the following characteristics:

- Ability to deploy Application Insights in the same resource group as the API manager.
- Ability to deploy Application Insights in the same resource group location in which the API manager is deployed.
- Also gives ability to specify the following for Application Insights based on the requirements:
  - name : Specifies the name of the Application Insights component. Changing this forces a new resource to be created.
  - application_type : Specifies the type of Application Insights to create. Valid values are ios for iOS, java for Java web, MobileCenter for App Center, Node.JS for Node.js, other for General, phone for Windows Phone, store for Windows Store and web for ASP.NET. Please note these values are case sensitive; unmatched values are treated as ASP.NET by Azure. Changing this forces a new resource to be created.
  - tags : A mapping of tags to assign to the resource.

Please click the [link](https://www.terraform.io/docs/providers/azurerm/r/application_insights.html) to get additional details on settings in Terraform for Azure Application Insights.

## Usage

```
resource "azurerm_application_insights" "apimgmt" {
  name                = "${var.appinsights_name}"
  resource_group_name = "${azurerm_resource_group.apimgmt.name}"
  location            = "${azurerm_resource_group.apimgmt.location}"
  application_type    = "${var.appinsights_application_type}"
  tags                = "${var.resource_tags}"
}
