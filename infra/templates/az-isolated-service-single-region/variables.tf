// ---- General Configuration ----

variable "name" {
  description = "An identifier used to construct the names of all resources in this template."
  type        = string
}

variable "randomization_level" {
  description = "Number of additional random characters to include in resource names to insulate against unexpected resource name collisions."
  type        = number
  default     = 8
}

variable "resource_group_location" {
  description = "The Azure region where all resources in this template should be created."
  type        = string
}



// ---- App Service Environment Configuration ----
variable "ase_subscription_id" {
  description = "The ID of the subscription in which the ASE lives in"
  type        = string
  default     = ""
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

variable "unauthn_deployment_targets" {
  description = "Metadata about apps to deploy, such as repository location, docker file metadata and image names"
  type = list(object({
    app_name                 = string
    repository               = string
    dockerfile               = string
    image_name               = string
    image_release_tag_prefix = string
  }))
}

variable "authn_deployment_targets" {
  description = "Metadata about apps to deploy that also require authentication."
  type = list(object({
    app_name                 = string
    repository               = string
    dockerfile               = string
    image_name               = string
    image_release_tag_prefix = string
  }))
}

// ---- App Service Authentication Configuration ----

variable "auth_suffix" {
  description = "A name to be appended to all azure ad applications."
  type        = string
  default     = "easy-auth"
}

variable "graph_role_id" {
  description = "ID for Application.ReadWrite.OwnedBy"
  type        = string
  default     = "824c81eb-e3f8-4ee6-8f6d-de7f50d565b7"
}

variable "graph_id" {
  description = "ID for Windows Graph API"
  type        = string
  default     = "00000002-0000-0000-c000-000000000000"
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
  default     = ""
}


// ---- Networking For App Dev Resources ----

variable "resource_ip_whitelist" {
  description = "A list of IPs and/or IP ranges that should have access to VNET isolated resources provisioned by this template"
  type        = list(string)
  default     = []
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
