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

variable "virtual_network_address_space" {
    type = "string",
    description = "The virtual network address space"
    default = "10.0.0.0/16"
}

variable "subnet_address_prefix" {
    type = "string",
    description = "The virtual network subnet address prefix"
    default = "10.0.1.0/24"
}