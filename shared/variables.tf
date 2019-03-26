variable "resource_group_location" {
    type = "string"
    description = "The name of the target location"
    default = "eastus"
}
variable "env" {
    type = "string",
    description = "The short name of the target env (i.e. dev, staging, or prod)"
    default = "dev"
}
variable "org" {
    type = "string",
    description = "The short name of the organization"
    default = "msft"
}

variable "keyvault_sku" {
  description = "SKU of the keyvault to create"
  default     = "standard"
}

variable "storage_account_name" {
  description = "Storage Account Name for backend"
}

variable "container_name" {
  description = "Storage Container Name for backend blob"
}

variable "access_key" {
  description = "Access Key for backend blob"
}
