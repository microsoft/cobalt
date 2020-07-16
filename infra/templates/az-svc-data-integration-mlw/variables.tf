// ---- General Configuration ----
variable "prefix" {
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

variable "app_service_settings" {
  description = "Map of app settings that will be applied across all provisioned app services."
  type        = map(string)
  default     = {}
}

variable "app_services" {
  description = "Metadata about the app services to be created."
  type = list(object({
    app_name         = string
    image            = string
    linux_fx_version = string
    app_command_line = string
    app_settings     = map(string)
  }))
}

// ---- App Service Environment Configuration ----
variable "ase_name" {
  description = "The name of the App Service Environment in which to deploy the app"
  type        = string
  default     = ""
}

variable "address_space" {
  description = "The address space that is used the virtual network. You can supply more than one address space. Changing this forces a new resource to be created"
  type        = list(string)
  default     = ["10.2.0.0/16"]
}


variable "subnet_address_prefix" {
  description = "The subnet address prefix to use for the subnet"
  type        = string
  default     = "10.2.1.0/24"
}

variable "function_subnet_address_prefix" {
  description = "The subnet address prefix to use for the subnet"
  type        = string
  default     = "10.2.2.0/24"
}

variable "subnet_service_endpoints" {
  description = "A list of the service endpoints for the subnet"
  type        = list(string)
  default     = ["Microsoft.Web", "Microsoft.ContainerRegistry", "Microsoft.AzureCosmosDB"]
}


variable "func_subnet_service_endpoints" {
  description = "A list of the service endpoints for the subnet"
  type        = list(string)
  default     = ["Microsoft.Web", "Microsoft.ContainerRegistry"]
}

variable "container_registry_sku" {
  description = "(Optional) The SKU name of the the container registry. Possible values are Basic, Standard and Premium."
  type        = string
  default     = "Premium"
}


// ----Function App Service Plan Configuration ----

variable "monitoring_dimension_values" {
  description = "Dimensions used to determine service plan scaling"
  type        = list(string)
  default     = ["*"]
}

variable "func_app_service_plan_kind" {
  description = "The kind of Service Plan to be created. Possible values are Windows/Linux/FunctionApp/App"
  type        = string
  default     = "FunctionApp"
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
    }
  ]
}

variable "func_app_service_plan_size" {
  description = "The size of the service plan instance."
  type        = string
  default     = "Y1"
}

variable "func_app_service_plan_tier" {
  description = "The tier under which the service plan is created."
  type        = string
  default     = "Dynamic"
}

variable "func_app_service_plan_reserved" {
  description = "Is the Service Plan to be created reserved. Possible values are true/false"
  type        = bool
  default     = true
}

// ----Function App Service Plan Configuration Ends----

variable "sys_storage_containers" {
  description = "The list of storage container names to create. Names must be unique per storage account."
  type        = list(string)
}

variable "app_storage_containers" {
  description = "The list of storage container names to create. Names must be unique per storage account."
  type        = list(string)
}


// ---- ML Workspace Configuration ----

variable "sku_name" {
  description = "SKU/edition of the Machine Learning Workspace"
  type        = string
  default     = "Enterprise"
}

// ---- Monitoring Service Configuration ----

variable "action_group_name" {
  description = "The name of the action group."
  type        = string
  default     = "Simple Default Action Group"
}

variable "action_group_email_receiver" {
  description = "The e-mail receiver for an alert rule resource."
  type        = string
  default     = ""
}

variable "metric_alert_name" {
  description = "The display name of a group of metric alert criteria."
  type        = string
  default     = "smpl Metric Alerts"
}

variable "metric_alert_frequency" {
  description = "The frequency with which the metric alert checks if the conditions are met."
  type        = string
  default     = "PT1M"
}

variable "metric_alert_period" {
  description = "The look back window over which metric values are checked. Value must be greater than 'frequency'."
  type        = string
  default     = "PT5M"
}

variable "metric_alert_criteria_namespace" {
  description = "A monitored resource namespace with configurable metric alert criteria."
  type        = string
  default     = "Microsoft.Web/serverfarms"
}

variable "metric_alert_criteria_name" {
  description = "A predefined Azure resource alert monitoring rule name."
  type        = string
  default     = "CpuPercentage"
}

variable "metric_alert_criteria_aggregation" {
  description = "The calculation used for building metric alert criteria."
  type        = string
  default     = "Average"
}

variable "metric_alert_criteria_operator" {
  description = "A logical operator used for building metric alert criteria."
  type        = string
  default     = "GreaterThan"
}

variable "metric_alert_criteria_threshold" {
  description = "The criteria threshold value that activates the metric alert."
  type        = number
  default     = 50
}

// ---- Function App Service Configuration ----

variable "fn_name_prefix" {
  description = "The function app prefix name"
  type        = string
  default     = "smpl-test"
}

variable "fn_app_config" {
  description = "Metadata about the app services to be created"
  type = map(object({
    image = string,
    zip   = string,
    hash  = string
  }))
  default = {}
}

// ---- Azure Data Factory Configuration ----

variable "adf_number_of_nodes" {
  description = "Number of nodes for the Managed Integration Runtime. Max is 10. Defaults to 1."
  type        = number
  default     = 1
}

variable "adf_max_parallel_executions_per_node" {
  description = " Defines the maximum parallel executions per node. Defaults to 1. Max is 16."
  type        = number
  default     = 1
}

variable "adf_trigger_interval" {
  description = "The interval for how often the trigger occurs. This defaults to 1."
  type        = number
  default     = 1
}

variable "adf_trigger_frequency" {
  description = "The trigger freqency. Valid values include Minute, Hour, Day, Week, Month. Defaults to Minute."
  type        = string
  default     = "Minute"
}


// ---- Cosmos Database Configuration ----
variable "primary_replica_location" {
  description = "The primary replica location for the cosmos database"
  type        = string
}
