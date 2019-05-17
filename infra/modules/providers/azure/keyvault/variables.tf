variable "keyvault_name" {
  description = "Name of the keyvault to create"
  default     = "spkeyvault"
}

variable "keyvault_sku" {
  description = "SKU of the keyvault to create"
  default     = "standard"
}

variable "resource_group_name" {
  description = "Default resource group name that the network will be created in."
}

variable "keyvault_key_permissions" {
  description = "Permissions that the service principal has for accessing keys from KeyVault"
  type        = "list"
  default     = ["create", "delete", "get"]
}

variable "keyvault_secret_permissions" {
  description = "Permissions that the service principal has for accessing secrets from KeyVault"
  type        = "list"
  default     = ["set", "delete", "get"]
}

variable "keyvault_certificate_permissions" {
  description = "Permissions that the service principal has for accessing certificates from KeyVault"
  type        = "list"
  default     = ["create", "delete", "get"]
}