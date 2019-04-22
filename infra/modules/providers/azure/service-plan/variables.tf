variable "name" {
  description = "(Required) Specifies the human consumable label for this resource."
  default     = ""
}

variable "resource_group_name" {
  description = "(Optional) The name of the resource group in which to create the storage account. Changing this forces a new resource to be created. If omitted, will create a new RG based on the `name` above"
  default     = ""
}

variable "resource_group_location" {
  description = "(Required) Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created. The full list of Azure regions can be found at https://azure.microsoft.com/regions"
}

variable "resource_tags" {
  description = "Map of tags to apply to taggable resources in this module.  By default the taggable resources are tagged with the name defined above and this map is merged in"
  type        = "map"
  default     = {}
}

variable "svcplan_name" {
    description = "(Required) The name of the servie plan to be created"
    default   = ""
}
variable "svcplan_tier" {
    description = "The tier under which the service plan is created. Details can be found at https://docs.microsoft.com/en-us/azure/app-service/overview-hosting-plans"
    default     = "Standard"
}
variable "svcplan_size" {
    description = "The compute and storage needed for the service plan to be deployed. Details can be found at https://azure.microsoft.com/en-us/pricing/details/app-service/windows/"
    default     = "S1"
}

variable "svcplan_kind" {
    description = "The kind of Service Plan to be created. Possible values are Windows/Linux/FunctionApp/App"
    default     = "Linux"
}

variable "svcplan_capacity" {
    description = "The capacity of Service Plan to be created."
    default     = "1"
}

variable "svcplan_reserved" {
    description = "Is the Service Plan to be created reserved. Possible values are true/false"
    default     = true
}