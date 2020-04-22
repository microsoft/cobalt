# Naming Conventions (Required)

variable "name" {
  description = "String value prepended to the name of each function app"
  type        = string
}

variable "function_app_config" {
  description = "Metadata about the app services to be created."
  type = map(object({
    image        = string
    app_settings = map(string)
  }))
  default = {}
}


# Dependent Services (Required)

variable "service_plan_id" {
  description = "The id of the service plan"
  type        = string
}

variable "storage_account_name" {
  description = "The resource name of the storage account"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which the service plan was created."
  type        = string
}


# Configuration Items (optional)

variable "instrumentation_key" {
  description = "The Instrumentation Key for the Application Insights component used for function app to be created"
  type        = string
  default     = ""
}

variable "runtime_version" {
  description = "String value prepended to the name of each function app"
  type        = string
  default     = "~2"
}

variable "is_always_on" {
  description = "Should the app be loaded at all times? Defaults to true."
  type        = string
  default     = true
}

variable "is_java" {
  description = "If Java ensure the proper App Settings for runtime is set."
  type        = bool
  default     = true
}

# Private Registry Settings (optional)

variable "docker_registry_server_url" {
  description = "The docker registry server URL for images."
  type        = string
  default     = "docker.io"
}

variable "docker_registry_server_username" {
  description = "The docker registry server username for images."
  type        = string
  default     = ""
}

variable "docker_registry_server_password" {
  description = "The docker registry server password for images."
  type        = string
  default     = ""
}


# VNET Restriction (optional)

variable "vnet_name" {
  description = "The integrated VNet name."
  type        = string
  default     = ""
}

variable "vnet_subnet_id" {
  description = "The VNet integration subnet gateway identifier."
  type        = string
  default     = ""
}

# General Items (optional)

variable "resource_tags" {
  description = "Map of tags to apply to taggable resources in this module. By default the taggable resources are tagged with the name defined above and this map is merged in"
  type        = map(string)
  default     = {}
}
