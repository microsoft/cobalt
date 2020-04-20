
variable "ad_app_config" {
  description = "Metadata about the app services to be created."
  type = list(object({
    app_name   = string
    reply_urls = list(string)
  }))
}

variable "resource_app_id" {
  description = "The id of the app registration that this resource require access to."
  type        = string
}

variable "resource_role_id" {
  description = "The id of the role provided by a resource app id."
  type        = string
}

variable "app_type" {
  description = "The type of application."
  type        = string
  default     = "webapp/api"
}

variable "available_to_other_tenants" {
  description = "Is this ad application available to other tenants?"
  type        = bool
  default     = false
}

variable "oauth2_allow_implicit_flow" {
  description = "Does this ad application allow oauth2 implicit flow tokens?"
  type        = bool
  default     = true
}

variable "resource_access_type" {
  description = "The type of role describing the role name of a resource access."
  type        = string
  default     = "Role"
}
