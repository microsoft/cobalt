variable "resource_group_name" {
  description = "The name of the resource group in which to create the storage account. Changing this forces a new resource to be created. If omitted, will create a new RG based on the `name` above"
  type        = "string"
}

variable "resource_tags" {
  description = "Map of tags to apply to taggable resources in this module.  By default the taggable resources are tagged with the name defined above and this map is merged in"
  type        = "map"
  default     = {}
}

variable "service_plan_name" {
  description = "The name of the service plan to be created"
  type        = "string"
}

variable "service_plan_tier" {
  description = "The tier under which the service plan is created. Details can be found at https://docs.microsoft.com/en-us/azure/app-service/overview-hosting-plans"
  type        = "string"
  default     = "Standard"
}

variable "service_plan_size" {
  description = "The compute and storage needed for the service plan to be deployed. Details can be found at https://azure.microsoft.com/en-us/pricing/details/app-service/windows/"
  type        = "string"
  default     = "S1"
}

variable "service_plan_kind" {
  description = "The kind of Service Plan to be created. Possible values are Windows/Linux/FunctionApp/App"
  type        = "string"
  default     = "Linux"
}

variable "service_plan_capacity" {
  description = "The capacity of Service Plan to be created."
  type        = "string"
  default     = "1"
}

variable "service_plan_reserved" {
  description = "Is the Service Plan to be created reserved. Possible values are true/false"
  type        = "string"
  default     = "true"
}
