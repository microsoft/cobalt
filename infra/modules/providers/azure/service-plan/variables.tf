variable "resource_group_name" {
  description = "Resource group name that the service plan will be created in."
  default     = "cblt-svcplan-rg"
}

variable "resource_group_location" {
  description = "Default resource group location that the resource group will be created in. The full list of Azure regions can be found at https://azure.microsoft.com/regions"
  type        = "string"
}

variable "svcplan_name" {
    description = "The name of the servie plan to be created"
    default   = "cblt-svcplan"
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
