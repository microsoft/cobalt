variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
}

# action group attributes
variable "action_group_name" {
  description = "The name of the action group."
  type        = string
}

variable "action_group_email_receiver" {
  description = "The e-mail receiver for an alert rule resource."
  type        = string
  default     = ""
}

variable "action_group_email_receiver_name" {
  description = "The e-mail receiver name for an alert group."
  type        = string
  default     = "E-mail Receiver"
}

variable "action_group_short_name" {
  description = "The abbreviated name of the action group."
  type        = string
  default     = "Notify"
}

# metric alert attributes
variable "resource_ids" {
  description = "Resource Ids to be monitored."
  type        = list(string)
}

variable "metric_alert_name" {
  description = "The display name of a group of metric alert criteria."
  type        = string
}

variable "metric_alert_criteria_name" {
  description = "A predefined Azure resource alert monitoring rule name."
  type        = string
}

variable "metric_alert_criteria_namespace" {
  description = "A monitored resource namespace that holds metric alert criteria."
  type        = string
}

variable "metric_alert_criteria_aggregation" {
  description = "The calculation used for building metric alert criteria."
  type        = string
}

variable "metric_alert_criteria_operator" {
  description = "A logical operator used for building metric alert criteria."
  type        = string
}

variable "metric_alert_criteria_threshold" {
  description = "The criteria threshold value that activates the metric alert."
  type        = string
}

variable "monitoring_dimension_values" {
  description = "Dimensions used to determine service plan scaling."
  type        = list(string)
}

variable "metric_alert_frequency" {
  description = "The frequency with which the metric alert checks if the conditions are met."
  type        = string
  default     = "PT1M"
}

variable "metric_alert_period" {
  description = "The look back window over which metric values are checked."
  type        = string
  default     = "PT5M"
}

