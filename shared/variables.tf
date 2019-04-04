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
