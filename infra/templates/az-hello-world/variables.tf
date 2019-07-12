variable "prefix" {
  description = "The prefix used for all resources in this example"
  type        = string
}

variable "resource_group_location" {
  description = "The Azure location where all resources in this example should be created."
  type        = string
}

variable "app_service_name" {
  description = "The name key value pair where the key is the name assigned to the app service and value is the source container."
  type        = map(string)
}

variable "app_service_auth" {
  description = "Properties for enabling Azure Ad authentication"
  type        = map(map(string))
}

variable "docker_registry_server_url" {
  description = "The url of the container registry that will be utilized to pull container into the Web Apps for containers"
  type        = string
  default     = "docker.io"
}

