variable "service_plan_resource_group_name" {
  description = "The name of the resource group in which the service plan was created."
  type        = "string"
}

variable "service_plan_name" {
  description = "The name of the service plan"
  type        = "string"
}

variable "resource_tags" {
description = "Map of tags to apply to taggable resources in this module. By default the taggable resources are tagged with the name defined above and this map is merged in"
type        = "map"
default     = {}
}

variable "app_service_name" {
  description = "The name of the app service to be created"
  type        = "list"
}

variable "docker_registry_server_url" {
  description = "The docker registry server URL for app service to be created"
  type        = "string"
}

variable "docker_registry_server_username" {
  description = "The docker registry server username for app service to be created"
  type        = "string"
}

variable "docker_registry_server_password" {
  description = "The docker registry server password for app service to be created"
  type        = "string"
}

variable "site_config_linux_fx_version" {
  description = "The Linux App Framework and version for the App Service to be created"
  type        = "list"
  default     = ["", ""]
}

variable "site_config_always_on" {
  description = "Should the app be loaded at all times? Defaults to false."
  type        = "bool"
  default     = false
}
