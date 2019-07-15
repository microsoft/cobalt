variable "prefix" {
  description = "The prefix used for all resources in this example"
  type        = string
}

variable "resource_group_location" {
  description = "The Azure location where all resources in this example should be created."
  type        = string
}

variable "deployment_targets" {
  description = "Metadata about apps to deploy, such as image metadata and authentication client id."
  type = list(object({
    app_name                 = string
    image_name               = string
    image_release_tag_prefix = string
    auth_client_id           = string
  }))
}

variable "enable_authentication" {
  description = "Determines whether or not to secure all applications with Azure AD."
  type        = bool
  default     = false
}

variable "docker_registry_server_url" {
  description = "The url of the container registry that will be utilized to pull container into the Web Apps for containers"
  type        = string
  default     = "docker.io"
}

variable "external_tenant_id" {
  description = "Tenant id for creating and registering Azure AD authentication."
  type        = string
  default     = ""
}
