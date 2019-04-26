variable "service_plan_resource_group_name" {
  description = "The name of the resource group in which the service plan was created."
  type        = "string"
}

variable "resource_tags" {
  description = "Map of tags to apply to taggable resources in this module.  By default the taggable resources are tagged with the name defined above and this map is merged in"
  type        = "map"
  default     = {}
}

variable "apimgmt_name" {
  description = "Name of the api management service to create"
  type        = "string"
}

variable "apimgmt_sku" {
  description = "SKU of the api management service to create"
  type        = "string"
  default     = "Premium"
}

variable "apimgmt_pub_name" {
  description = "API management publisher name"
  type        = "string"
  default     = "mycompany.co"
}

variable "apimgmt_pub_email" {
  description = "API management publisher name"
  type        = "string"
  default     = "terraform@mycompany.co"
}

variable "apimgmt_capacity" {
    type    = "string"
    default = "1"
}
