// ---- General Configuration ----

variable "resource_group_location" {
  description = "The deployment location of resource group container all the resources"
  type        = string
}

variable "name" {
  description = "The name of the deployment. This will be used across the resource created in this solution"
  type        = string
}



// ---- App Service Environment Configuration ----
variable "ase_subscription_id" {
  description = "The ID of the subscription in which the ASE lives in"
  type        = string
}

variable "ase_name" {
  description = "The name of the App Service Environment in which to deploy the app services"
  type        = string
}

variable "ase_resource_group" {
  description = "The resource group of the App Service Environment in which to deploy the app services"
  type        = string
}

variable "ase_vnet_name" {
  description = "The name of the VNET that the App Service Environment is deployed to"
  type        = string
}




// ---- App Service Configuration ----

variable "app_service_name" {
  description = "The name key value pair where the key is the name assigned to the app service and value is the source container"
  type        = map(string)
}


// ---- Service Plan Configuration ----

variable "monitoring_dimension_values" {
  description = "Dimensions used to determine service plan scaling"
  type        = list(string)
  default     = ["*"]
}

variable "service_plan_size" {
  description = "The size of the service plan instance. Valid values are I1, I2, I3. See more here: . Details can be found at https://azure.microsoft.com/en-us/pricing/details/app-service/windows/"
  type        = string
  default     = "I1"
}

variable "service_plan_kind" {
  description = "The kind of Service Plan to be created. Possible values are Windows/Linux/FunctionApp/App"
  type        = string
  default     = "Linux"
}


variable "scaling_rules" {
  description = "The scaling rules for the app service plan. Schema defined here: https://www.terraform.io/docs/providers/azurerm/r/monitor_autoscale_setting.html#rule. Note, the appropriate resource ID will be auto-inflated by the template"
  type = list(object({
    metric_trigger = object({
      metric_name      = string
      time_grain       = string
      statistic        = string
      time_window      = string
      time_aggregation = string
      operator         = string
      threshold        = number
    })
    scale_action = object({
      direction = string
      type      = string
      cooldown  = string
      value     = number
    })
  }))
  default = [
    {
      metric_trigger = {
        metric_name      = "CpuPercentage"
        time_grain       = "PT1M"
        statistic        = "Average"
        time_window      = "PT5M"
        time_aggregation = "Average"
        operator         = "GreaterThan"
        threshold        = 70
      }
      scale_action = {
        direction = "Increase"
        type      = "ChangeCount"
        value     = 1
        cooldown  = "PT10M"
      }
      }, {
      metric_trigger = {
        metric_name      = "CpuPercentage"
        time_grain       = "PT1M"
        statistic        = "Average"
        time_window      = "PT5M"
        time_aggregation = "Average"
        operator         = "GreaterThan"
        threshold        = 25
      }
      scale_action = {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = 1
        cooldown  = "PT1M"
      }
    }
  ]
}


// ---- App Dev Subscription ----

variable "app_dev_subscription_id" {
  description = "Subscription in which the application dependencies will be deployed to"
  type        = string
}


# Note: We won't be supporting monitoring rules until we have more direction from the
# customer about how they will use these... However, the schema is useful so I'll keep
# it defined here.
#
# variable "monitoring_rules" {
#   description = "List of monitoring/alerting rules that should be applied to the deployment"
#   type = list(object({
#     action_group_name           = string
#     action_group_email_receiver = string
#     metrics = list(object({
#       metric_alert_name                 = string
#       metric_alert_frequency            = string
#       metric_alert_period               = string
#       metric_alert_criteria_namespace   = string
#       metric_alert_criteria_name        = string
#       metric_alert_criteria_aggregation = string
#       metric_alert_criteria_operator    = string
#       metric_alert_criteria_threshold   = string
#     }))
#   }))
#   default = []
# }
