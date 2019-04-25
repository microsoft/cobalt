variable "resource_group_name" {
  description = "The name of the resource group in which to create the storage account. Changing this forces a new resource to be created. If omitted, will create a new RG based on the `name` above"
  type        = "string"
}

variable "resource_group_location" {
  description = "Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created. The full list of Azure regions can be found at https://azure.microsoft.com/regions"
  type        = "string"  
}

variable "resource_tags" {
description = "Map of tags to apply to taggable resources in this module.  By default the taggable resources are tagged with the name defined above and this map is merged in"
type        = "map"
default     = {}
}

variable "app_service_plan_id" {
  description = "The ID of the service plan under which the app service needs to be created"
  type        = "string"
}

variable "app_service_name" {
  description = "The name of the app service to be created"
  type        = "string"
}
