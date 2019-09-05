variable "prefix" {
  description = "The prefix used for all resources in this example"
  type        = string
}

variable "resource_group_location" {
  description = "The Azure location where all resources in this example should be created."
  type        = string
}

variable "deployment_targets" {
  description = "Metadata about apps to deploy, such as image metadata."
  type = list(object({
    app_name                 = string
    image_name               = string
    image_release_tag_prefix = string
  }))
}

variable "docker_registry_server_url" {
  description = "The url of the container registry that will be utilized to pull container into the Web Apps for containers"
  type        = string
  default     = "docker.io"
}

