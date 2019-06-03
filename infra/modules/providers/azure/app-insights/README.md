# Azure Application Insights

Application Insights is an extensible Application Performance Management (APM) service for web developers on multiple platforms. It is used to monitor live web applications and can automatically detect performance anomalies. It also includes powerful analytics tools to help diagnose issues and to understand what users actually do with an app.

More information for Azure Application Insights can be found [here](https://docs.microsoft.com/en-us/azure/azure-monitor/app/app-insights-overview).

This directory contains a terraform module in Cobalt to create a new instance of Application Insights.

The following characteristics can be specified by the user:

  - name: Specifies the name of the Application Insights component. Changing this forces a new resource to be created.
  - application_type: Specifies the type of Application Insights to create. Valid values are ios for iOS, java for Java web, MobileCenter for App Center, Node.JS for Node.js, other for General, phone for Windows Phone, store for Windows Store and web for ASP.NET. Please note these values are case sensitive; unmatched values are treated as ASP.NET by Azure. Changing this forces a new resource to be created.
  - resource_group_name: Specifies the resource group where the Service Plan was deployed (so the Application Insights instance gets deployed to the same resource group)
  - tags : A mapping of tags to assign to the resource.

Please click the [link](https://www.terraform.io/docs/providers/azurerm/r/application_insights.html) to get additional details on settings in Terraform for Azure Application Insights.

## Usage

Use of this App Insights module assumes that a resource group has already been created, and that an App Service Plan has already been deployed to it.  The Cobalt module to deploy an App Service Plan is located [here](infra/modules/providers/azure/service-plan).

### Usage in a Cobalt Template

Sample usage of the Service Plan and App Insights modules in a Cobalt template:

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

variable "application_type" {
  value = "Node.JS"
}

variable "resource_tags" {
  value = "{}"
}

module "service_plan" {
  source                  = "<URL or path to module>"
  resource_group_name     = "${var.resource_group_name}"
  resource_group_location = "${var.resource_group_location}"
  service_plan_name       = "${var.service_plan_name}"
}

module "app_insights" {
  source                               = "<URL or path to module>"
  service_plan_resource_group_name     = "${var.resource_group_name}"
  appinsights_name                     = "${var.appinsights_name}"
  application_type                     = "${var.application_type}"
  resource_tags                        = "${var.resource_tags}"
}
```

### Manual Execution with Terraform

Note: Terraform will prompt for any variable values which are not passed into the `plan` or `apply` command, and for which default values are not set.

Sample manual execution of the module using Terraform from within the `infra/modules/providers/azure/app-insights` directory is shown below.

Note: Descriptions for each value are located in the `variables.tf` file.

```
c:\Users\user\repos\cobalt\infra\modules\providers\azure\app-insights>terraform apply
var.appinsights_application_type
  Type of the App Insights Application.  Valid values are ios for iOS, java for Java web, MobileCenter for App Center, Node.JS for Node.js, other for General, phone for Windows Phone, store for Windows Store and web for ASP.NET.

  Enter a value: Node.JS

var.appinsights_name
  Name of the App Insights to create

  Enter a value: test-app-insights

var.resource_tags
  Map of tags to apply to taggable resources in this module (enter as a set of curly braces containing key-value pairs, as in: {"tag1" = "value1", "tag2" = "value2"}).  By default the taggable resources are tagged with the name defined above and this map is merged in

  Enter a value: {"tag1" = "value1", "tag2" = "value2"}

var.service_plan_resource_group_name
  The name of the resource group in which the service plan was created.

  Enter a value: test-rg
  ```

Terraform will output its execution plan and requires the user to approve the changes by typing "yes":

```
data.azurerm_resource_group.appinsights: Refreshing state...

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  + azurerm_application_insights.appinsights
      id:                  <computed>
      app_id:              <computed>
      application_type:    "Node.JS"
      instrumentation_key: <computed>
      location:            "eastus"
      name:                "test-app-insights"
      resource_group_name: "test-rg"
      tags.%:              <computed>


Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes
```

The module will then deploy the App Insights instance specified above:

```
azurerm_application_insights.appinsights: Creating...
  app_id:              "" => "<computed>"
  application_type:    "" => "Node.JS"
  instrumentation_key: "<sensitive>" => "<sensitive>"
  location:            "" => "eastus"
  name:                "" => "test-app-insights"
  resource_group_name: "" => "test-rg"
  tags.%:              "" => "<computed>"
azurerm_application_insights.appinsights: Creation complete after 8s (ID: /subscriptions/xxxxbca0-7axx-xxbd-b5xx-...sights/components/test-app-insights)

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```


## Output

Once the deployments are completed successfully, the output for the App Insights module will be in the format shown below:

```
Outputs:

app_insights_app_id = xxxx5ba9-f5xx-xx94-93xx-xxxx0d40xxxx
app_insights_instrumentation_key = xxxx75785-xx5f-42xx-xx80-xxxxx94c93xx
```
