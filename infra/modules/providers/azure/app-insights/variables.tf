variable "service_plan_resource_group_name" {
  description = "The name of the resource group in which the service plan was created."
  type        = string
}

variable "resource_tags" {
  description = "Map of tags to apply to taggable resources in this module (enter as a set of curly braces containing key-value pairs, as in: {\"tag1\" = \"value1\", \"tag2\" = \"value2\"}).  By default the taggable resources are tagged with the name defined above and this map is merged in"
  type        = map(string)
  default     = {}
}

variable "appinsights_name" {
  description = "Name of the App Insights to create"
  type        = string
}

variable "appinsights_application_type" {
  description = "Type of the App Insights Application.  Valid values are ios for iOS, java for Java web, MobileCenter for App Center, Node.JS for Node.js, other for General, phone for Windows Phone, store for Windows Store and web for ASP.NET."
  type        = string
}

