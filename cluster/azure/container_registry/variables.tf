variable "container_registry_name" {
  description = "Name of the Azure Container Registry to be created"
  default     = "acctcontainer_registry"
}

variable "container_registry_sku" {
  description = "SKU of the Azure Container Registry to create"
  default     = "Basic"
}

variable "resource_group_name" {
  description = "Default resource group name that the network will be created in."
  default     = "myapp-rg"
}

variable "location" {
  description = "The location/region where the core network will be created. The full list of Azure regions can be found at https://azure.microsoft.com/regions"
  type = "string"
}
