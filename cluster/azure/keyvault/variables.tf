variable "location" {
    type = "string"
    description = "The name of the target location"
}
variable "env" {
    type = "string",
    description = "The short name of the target env (i.e. dev, staging, or prod)"
}
variable "org" {
    type = "string",
    description = "The short name of the organization"
}

variable "keyvault_name" {
  description = "Name of the keyvault to create"
  default     = "acctkeyvault1"
}

variable "keyvault_sku" {
  description = "SKU of the keyvault to create"
  default     = "standard"
}

variable "resource_group_name" {
  description = "Default resource group name that the network will be created in."
  default     = "myapp-rg"
}

