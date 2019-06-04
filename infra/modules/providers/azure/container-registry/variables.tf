variable "resource_group_name" {
  description = "(Required) The name of the resource group in which to create the Container Registry. Changing this forces a new resource to be created."
  type        = "string"
}

variable "container_registry_name" {
  description = "(Required) Specifies the name of the Container Registry. Changing this forces a new resource to be created."
  type        = "string"
}

variable "container_registry_admin_enabled" {
  description = "(Optional) Specifies whether the admin user is enabled. Defaults to false."
  default     = false
}

variable "container_registry_sku" {
  description = "(Optional) The SKU name of the the container registry. Possible values are Basic, Standard and Premium."
  type        = "string"
  default     = "Basic"
}

variable "container_registry_tags" {
  description = "(Optional) A mapping of tags to assign to the resource."
  type        = "map"
  default     = {}
}
