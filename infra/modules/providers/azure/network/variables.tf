variable "resource_group_name" {
  description = "(Required) The name of the resource group in which to create the Container Registry. Changing this forces a new resource to be created."
  type        = string
}

variable "vnet_name" {
  description = "The vnet integration name."
  type        = string
}

variable "address_space" {
  description = "The address space that is used the virtual network. You can supply more than one address space. Changing this forces a new resource to be created"
  type        = list(string)
  default     = ["10.2.0.0/16"]
}

variable "subnets" {
  description = ""
  type = list(object({
    name                = string
    resource_group_name = string
    address_prefix      = string
    service_endpoints   = list(string)
    delegation = object({
      name = string
      service_delegation = object({
        name    = string
        actions = list(string)
      })
    })
  }))
}
