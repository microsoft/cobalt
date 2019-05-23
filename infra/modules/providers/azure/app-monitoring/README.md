# Azure Monitor

This custom Terraform based `app-monitoring` module is recommended for monitoring Azure Resources externally servicing an App service (ex. App Service Plan, App Gateway, VM, etc.). For monitoring the `metrics` emitted at the App Service level, Azure Monitor relies on application insights. The `app-insights` module can be found here.

This module can be used by Cobalt Templates in order to map configurable `alert criteria` to individual Azure Resources offered by the Azure Monitor Service for monitoring. Monitored `alert criteria` comes in two forms, `metrics` and `logs`. This module introduces monitoring for `metrics` only. As a result, this module offers configurable `metric alert criteria`. How `metric alert criteria` is configured depends on the type of predefined metrics offered by the particular Azure Resource being referenced for monitoring. (ex. The App Service Plan Resource offers 'CpuMonitoring' as a configurable `metric`.)

In addition to the `metric alert criteria`, this module introduces a configurable `action group` that when paired with `metric alert criteria` can trigger event types like e-mail notifications.

##### More on Azure Monitoring

"Azure Monitor maximizes the availability and performance of your applications by delivering a comprehensive solution for collecting, analyzing, and acting on telemetry from your cloud and on-premises environments. ..All data collected by Azure Monitor fits into one of two fundamental types, metrics and logs. Metrics are numerical values that describe some aspect of a system at a particular point in time. They are lightweight and capable of supporting near real-time scenarios. Logs contain different kinds of data organized into records with different sets of properties for each type." - Source: [Azure Monitor Documentation](https://docs.microsoft.com/en-us/azure/azure-monitor/overview)

##### More on Terraform Resource

- `azurerm_monitor_metric_alert`
- `azurerm_monitor_action_group`

## Characteristics

A terraform module in Cobalt that leverages the "Azure Monitor Service" in order to provide Cobalt Templates with the following characteristics:

- Ability to deploy Azure Monitor in the same resource group as the Service Plan.

- Ability to deploy Azure Monitor with configurable metric alert criteria scoped to target growing Azure resources.

- Ability to deploy Azure Monitor with configurable metric alert criteria all paired to a single action group.

### Module Usage

- Service Plan Module : infra/modules/providers/azure/service-plan
- App Monitoring Module

```
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

module "app_monitoring_app_service" {
  source                            = "../../modules/providers/azure/app-monitoring"
  resource_group_name               = "${azurerm_resource_group.svcplan.name}"
  resource_ids                      = ["${module.service_plan.app_service_plan_id}"]
  action_group_email_receiver       = "${var.action_group_email_receiver}"
  metric_alert_criteria_namespace   = "${var.metric_alert_criteria_namespace}"
  alert_metric_name                 = "${var.alert_metric_name}"
  metric_alert_criteria_aggregation = "${var.metric_alert_criteria_aggregation}"
  metric_alert_criteria_operator    = "${var.metric_alert_criteria_operator}"
  metric_alert_criteria_threshold   = "${var.metric_alert_criteria_threshold}"
}
```

## Output

Once the deployments are completed successfully, the output for the current module will be in the format mentioned below:

```
Outputs:

rule_resource_id = xxxx5ba9-f5xx-xx94-93xx-xxxx0d40xxxx
```