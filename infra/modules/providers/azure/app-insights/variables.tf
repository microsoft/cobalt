variable "service_plan_resource_group_name" {
  description = "The name of the resource group in which the service plan was created."
  type        = "string"
}

variable "resource_tags" {
  description = "Map of tags to apply to taggable resources in this module.  By default the taggable resources are tagged with the name defined above and this map is merged in"
  type        = "map"
  default     = {}
}

variable "appinsights_name" {
  description = "Name of the App Insights to create"
  type        = "string"
}

variable "appinsights_application_type" {
  description = "Type of the App Insights Application"
  type        = "string"
  default     = "Web"
}