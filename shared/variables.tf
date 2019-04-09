variable "location" {
    type = "string"
    description = "The name of the target location"
    default = "eastus"
}
variable "company" {
    type = "string",
    description = "The short name of the company/app"
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
