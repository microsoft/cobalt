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

variable "api_name" {
  description = "Name of the api to manage"
  type        = "string"
}

variable "revision" {
  description = "The Revision which used for this API."
  type        = "string"
  default     = "1"
}

variable "display_name" {
  description = "The display name of the API."
  type        = "string"
  default     = "Example API"
}

variable "path" {
  description = "The Path for this API Management API, which is a relative URL which uniquely identifies this API and all of it's resource paths within the API Management Service."
  type        = "string"
  default     = "example"
}

variable "protocols" {
  description = "A list of protocols the operations in this API can be invoked. Possible values are http and https."
  type        = "list"
  default     = ["https"]
}

variable "service_url" {
  description = "Absolute URL of the backend service implementing this API."
  type        = "list"
}
