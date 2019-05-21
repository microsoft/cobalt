# Resource Group
variable "resource_group_location" {
  description = "The deployment location of resource group container all the resources"
  type        = "string"
}

variable "name" {
  description = "The name of the deployment.  This will be used across the resource created in this solution"
  type        = "string"
}

variable "app_service_name" {
  description = "The name key value pair where the key is the name assigned to the app service and value is the source container"
  type        = "map"
}

variable "subnet_service_endpoints" {
  description = "The list of service endpoints that will be given to each subnet"
  type        = "list"
  default     = ["Microsoft.Web"]
}

variable "address_space" {
  description = "The address space that is used by the virtual network."
  default     = "10.0.0.0/16"
}

variable "subnet_names" {
  description = "A list of public subnets inside the vNet."
  default     = ["app-gateway"]
}

variable "subnet_prefixes" {
  description = "The address prefix to use for the subnet."
  default     = ["10.0.1.0/24"]
}

variable "appgateway_backend_http_protocol" {
  description = "The backend protocol for the Appication Gateway to be created"
  default     = "Https"
}

variable "appgateway_http_listener_protocol" {
  description = "The Http Listener protocol for the Appication Gateway to be created"
  default     = "Https"
}

# App Service

variable "docker_registry_server_url" {
  description = "The url of the container registry that will be utilized to pull container into the Web Apps for containers"
  type        = "string"
  default     = "index.docker.io"
}

variable "docker_registry_server_username" {
  description = "The username used to authenticate with the container registry"
  type        = "string"
  default     = ""
}

variable "docker_registry_server_password" {
  description = "The password used to authenticate with the container regitry"
  type        = "string"
  default     = ""
}
