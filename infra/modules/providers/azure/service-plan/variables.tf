variable "resource_group_name" {
  description = "The name of the resource group in which to create the storage account. Changing this forces a new resource to be created. If omitted, will create a new RG based on the `name` above"
  type        = string
}

variable "resource_tags" {
  description = "Map of tags to apply to taggable resources in this module.  By default the taggable resources are tagged with the name defined above and this map is merged in"
  type        = map(string)
  default     = {}
}

variable "service_plan_name" {
  description = "The name of the service plan to be created"
  type        = string
}

variable "service_plan_tier" {
  description = "The tier under which the service plan is created. Details can be found at https://docs.microsoft.com/en-us/azure/app-service/overview-hosting-plans"
  type        = string
  default     = "Standard"
}

variable "service_plan_size" {
  description = "The compute and storage needed for the service plan to be deployed. Details can be found at https://azure.microsoft.com/en-us/pricing/details/app-service/windows/"
  type        = string
  default     = "S1"
}

variable "service_plan_kind" {
  description = "The kind of Service Plan to be created. Possible values are Windows/Linux/FunctionApp/App"
  type        = string
  default     = "Linux"
}

variable "service_plan_capacity" {
  description = "The capacity of Service Plan to be created."
  type        = number
  default     = 1
}

variable "service_plan_reserved" {
  description = "Is the Service Plan to be created reserved. Possible values are true/false"
  type        = bool
  default     = true
}

variable "app_service_environment_id" {
  description = "If specified, the ID of the App Service Environment where this plan should be deployed"
  type        = string
  default     = ""
}

variable "autoscale_capacity_minimum" {
  description = "The minimum number of instances for this resource. Valid values are between 0 and 1000"
  type        = number
  default     = 1
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
        operator         = "LessThan"
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
