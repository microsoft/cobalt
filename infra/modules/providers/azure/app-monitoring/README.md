# Azure Monitor

This Terraform based `app-monitoring` module grants templates the ability to define and assign `alert criteria` to "Azure Resources" using Microsoft's _**Azure Monitor**_ service. `alert criteria` is conditional logic that targets a list of one or more "Azure Resources" for the purposes of monitoring their behavior. `alert criteria` comes in two forms, `metrics` and `logs`. This module introduces `metrics` based monitoring only. As a result, `alert criteria` in the context of this module is refered to as `metric alert criteria`. The way `metric alert criteria` is configured depends entirely on the `metrics` options offered by the "Azure Resources" selected for monitoring. (ex. The App Service Plan resource offers 'CpuMonitoring' as a configurable `metric`.)

In addition to the `metric alert criteria`, this module introduces a configurable `action group` that when paired with `metric alert criteria` can be configured to trigger events like e-mail notifications.

#### _More on Azure Monitoring_

> "Azure Monitor maximizes the availability and performance of your applications by delivering a comprehensive solution for collecting, analyzing, and acting on telemetry from your cloud and on-premises environments.
> All data collected by Azure Monitor fits into one of two fundamental types, metrics and logs. Metrics are numerical values that describe some aspect of a system at a particular point in time. They are lightweight and capable of supporting near real-time scenarios. Logs contain different kinds of data organized into records with different sets of properties for each type." - Source: Microsoft's [Azure Monitor Service Overview](https://docs.microsoft.com/en-us/azure/azure-monitor/overview)

This module deploys the _**Azure Monitor**_ service in order to offer visibility into the behavior of your deployed "Azure Resources". This module is recommended for `metrics` based monitoring of any "Azure Resource" deployed alongside App Services (ex. App Service Plan, App Gateway, VM, etc.). The list of `metrics` available for configuration depends entirely on the Azure Resource chosen to be monitored. For more information on how `metrics` work, please visit Microsoft's [alerts-metric-overview](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/alerts-metric-overview) documentation.

For monitoring of an App Service, the [app-insights](../app-insights) module is instead recommended. The [app-insights](../app-insights) module leverages an _**Azure Monitor**_ service called [application insights](https://www.terraform.io/docs/providers/azurerm/r/application_insights.html).

## Characteristics

An instance of the `app-monitoring` module deploys the _**Azure Monitor**_ service in order to provide templates with the following:

- Ability to deploy Azure Monitor within a single resource group.

- Ability to deploy Azure Monitor with a single set of configurable `metric alert criteria` targeting one or more Azure resources.

- Ability to deploy Azure Monitor with a single set of configurable `metric alert criteria` tied to a single `action group`.

## Definition

App Monitoring definition example:

```terraform
resource "azurerm_monitor_action_group" "appmonitoring" {
  count               = "${var.action_group_email_receiver == "" ? 0 : 1}"
  name                = "${var.action_group_name}"
  resource_group_name = "${var.resource_group_name}"
}

resource "azurerm_monitor_metric_alert" "appmonitoring" {
  count               = "${var.action_group_email_receiver == "" ? 0 : 1}"
  name                = "${var.metric_alert_name}"
  resource_group_name = "${azurerm_monitor_action_group.appmonitoring.resource_group_name}"
  scopes              = ["${var.resource_ids}"]

  criteria {
    metric_namespace = "${var.metric_alert_criteria_namespace}"
    metric_name      = "${var.metric_alert_criteria_name}"
    aggregation      = "${var.metric_alert_criteria_aggregation}"
    operator         = "${var.metric_alert_criteria_operator}"
    threshold        = "${var.metric_alert_criteria_threshold}"
  }

  action {
    action_group_id = "${azurerm_monitor_action_group.appmonitoring.id}"
  }
}
```

Terraform resources used to define the `app-monitoring` module include the following:

- [azurerm_monitor_metric_alert](https://www.terraform.io/docs/providers/azurerm/r/monitor_metric_alert.html)

- [azurerm_monitor_action_group](https://www.terraform.io/docs/providers/azurerm/r/monitor_action_group.html)

## Usage

App Monitoring usage example:

```terraform
variable "resource_group_name" {
  value = "test-rg"
}

variable "service_plan_name" {
  value = "test-svcplan"
}

module "service_plan" {
  resource_group_name     = "${var.resource_group_name}"
  resource_group_location = "${var.resource_group_location}"
  service_plan_name       = "${var.service_plan_name}"
}

module "app_monitoring" {
  source                            = "../../modules/providers/azure/app-monitoring"
  resource_group_name               = "${module.service_plan.resource_group_name}"
  resource_ids                      = ["${module.service_plan.app_service_plan_id}"]
  action_group_name                 = "${var.action_group_name}"
  action_group_email_receiver       = "${var.action_group_email_receiver}"
  metric_alert_name                 = "${var.metric_alert_name}"
  metric_alert_frequency            = "${var.metric_alert_frequency}"
  metric_alert_period               = "${var.metric_alert_period}"
  metric_alert_criteria_namespace   = "${var.metric_alert_criteria_namespace}"
  metric_alert_criteria_name        = "${var.metric_alert_criteria_name}"
  metric_alert_criteria_aggregation = "${var.metric_alert_criteria_aggregation}"
  metric_alert_criteria_operator    = "${var.metric_alert_criteria_operator}"
  metric_alert_criteria_threshold   = "${var.metric_alert_criteria_threshold}"
  monitoring_dimension_values       = "${var.monitoring_dimension_values}"
}
```

#### Configuring `resource_ids`

Please visit _**Azure Monitor's**_ [monitoring at scale](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/alerts-metric-overview#monitoring-at-scale-using-metric-alerts-in-azure-monitor.) page for more information on choosing multiple "Azure Resources".

- Resource IDs can either be a list of VM IDs or a single Azure Resource ID.

#### Configuring `metric alert criteria`

Please visit _**Azure Monitor's**_ [Supported Metrics](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/metrics-supported) page for a complete list of supported metrics per "Azure Resource".

1. View the list of 'metrics' offered by the namespace of your chosen "Azure Resource".
2. Choose a metric.
3. Define the metric's criteria (i.e. Conditional logic being applied to an "Azure Resource".)
4. Apply that criteria to your chosen or newly created template.

#### Configuring `action group`

Please visit _**Azure Monitor's**_ [action-groups](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/action-groups) page for more information on e-mail action groups.

1. Choose an appropriate e-mail address to receive alert notifications.
2. Choose an appropriate name for the 'action group' that will hold the e-mail address. (ex. "E-mail Alert Group")
3. Apply the e-mail address and name to your chosen or newly created template.

## Argument Reference

Supported arguments for this module are available in [variables.tf](variables.tf).

## Attributes Reference

The following attributes are exported:

- `rule_resource_id`: The ID of the metric alert.
