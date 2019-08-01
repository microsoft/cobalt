variable "keyvault_id" {
  type        = string
  description = "Default resource group name that the network will be created in."
}

variable "secrets" {
  description = "List of keyvault secret name and values."
  type = list(object({
    name  = string
    value = string
  }))
}
