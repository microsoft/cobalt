variable "resource_group_name" {
  description = "Resource group name that the app gateway will be created in."
  type        = "string"
}

variable "virtual_network_name" {
  description = "Virtual Network name that the app gateway will be created in."
  type        = "string"
}

variable "subnet_name" {
  description = "Subnet name that the app gateway will be created in."
  type        = "string"
}

variable "resource_tags" {
  description = "Map of tags to apply to taggable resources in this module.  By default the taggable resources are tagged with the name defined above and this map is merged in"
  type        = "map"
  default     = {}
}

variable "appgateway_name" {
  description = "The name of the application gateway"
  type        = "string"
}

variable "appgateway_sku_name" {
  description = "The SKU for the Appication Gateway to be created"
  type        = "string"
  default     = "Standard_Small"
}

variable "appgateway_tier" {
  description = "The tier of the application gateway. Small/Medium/Large. More details can be found at https://azure.microsoft.com/en-us/pricing/details/application-gateway/"
  type        = "string"
  default     = "Standard"
}

variable "appgateway_capacity" {
  description = "The capacity of application gateway to be created"
  type        = "string"
  default     = "1"
}

variable "appgateway_ipconfig_name" {
  description = "The IP Config Name for the Appication Gateway to be created"
  type        = "string"
}

variable "appgateway_frontend_port_name" {
  description = "The Frontend Port Name for the Appication Gateway to be created"
  type        = "string"
}

variable "frontend_http_port" {
  description = "The frontend port for the Appication Gateway to be created"
  type        = "string"
  default     = "80"
}

variable "appgateway_frontend_ip_configuration_name" {
  description = "The Frontend IP configuration name for the Appication Gateway to be created"
  type        = "string"
}

variable "frontend_ip_config_subnet_id" {
  description = "The Frontend subnet ID configuration for the Appication Gateway to be created"
  type        = "string"
  default     = ""
}

variable "frontend_ip_config_private_ip_address" {
  description = "The Frontend private IP configuration address for the Appication Gateway to be created"
  type        = "string"
  default     = ""
}

variable "frontend_ip_config_public_ip_address_id" {
  description = "The Frontend public IP configuration address for the Appication Gateway to be created"
  type        = "string"
  default     = ""
}

variable "appgateway_backend_address_pool_name" {
  description = "The Backend Addres Pool Name for the Appication Gateway to be created"
  type        = "string"
}

variable "appgateway_backend_address_pool_ipaddresses" {
  description = "A list of IP Addresses which should be part of the Backend Address Pool for the Appication Gateway to be created"
  type        = "list"
}

variable "appgateway_backend_http_setting_name" {
  description = "The Backend Http Settings Name for the Appication Gateway to be created"
  type        = "string"
}

variable "backend_http_cookie_based_affinity" {
  description = "The Backend Http cookie based affinity for the Appication Gateway to be created"
  type        = "string"
  default     = "Disabled"
}

variable "backend_http_port" {
  description = "The backend port for the Appication Gateway to be created"
  type        = "string"
  default     = "80"
}

variable "backend_http_protocol" {
  description = "The backend protocol for the Appication Gateway to be created"
  type        = "string"
  default     = "Http"
}

variable "http_listener_protocol" {
  description = "The Http Listener protocol for the Appication Gateway to be created"
  type        = "string"
  default     = "Http"
}

variable "appgateway_listener_name" {
  description = "The Listener Name for the Appication Gateway to be created"
  type        = "string"
}

variable "appgateway_request_routing_rule_name" {
  description = "The rule name to request routing for the Appication Gateway to be created"
  type        = "string"
}

variable "request_routing_rule_type" {
  description = "The rule type to request routing for the Appication Gateway to be created"
  type        = "string"
  default     = "Basic"
}
