variable "keyvault_id" {
  type        = string
  description = "Default resource group name that the network will be created in."
}

variable "secrets" {
  description = "Key/value pair of keyvault secret names and corresponding secret value."
  type = map(string)
}
