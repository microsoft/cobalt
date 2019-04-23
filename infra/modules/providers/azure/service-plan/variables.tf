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

variable "service_plan_name" {
    description = "(Optional) The name of the service plan to be created"
    default   = ""
}

variable "service_plan_tier" {
    description = "The tier under which the service plan is created. Details can be found at https://docs.microsoft.com/en-us/azure/app-service/overview-hosting-plans"
    default     = "Standard"
}

variable "service_plan_size" {
    description = "The compute and storage needed for the service plan to be deployed. Details can be found at https://azure.microsoft.com/en-us/pricing/details/app-service/windows/"
    default     = "S1"
}

variable "service_plan_kind" {
    description = "The kind of Service Plan to be created. Possible values are Windows/Linux/FunctionApp/App"
    default     = "Linux"
}

variable "service_plan_capacity" {
    description = "The capacity of Service Plan to be created."
    default     = "1"
}

variable "service_plan_reserved" {
    description = "Is the Service Plan to be created reserved. Possible values are true/false"
    default     = true
}

variable "app_service_name" {
    description = "The name of the app service to be created"
    default   = ""
}

variable "public_ip_name" {
    description = "The name of the Public IP to be created"
    default   = ""
}

variable "public_ip_sku" {
    description = "The SKU of the Public IP to be created. Accepted values are Basic and Standard"
    default   = "Basic"
}

variable "public_ip_alloc_method" {
    description = "The Allocation method for Public IP to be created (Static/Dynamic)"
    default   = "Static"
}

variable "load_balancer_name" {
    description = "The name of the load balancer to be created"
    default   = ""
}
