variable "resource_group_name" {
  description = "Resource group name that the app gateway will be created in."
}

variable "resource_group_location" {
  description = "Resource group location that the app gateway will be created in. The full list of Azure regions can be found at https://azure.microsoft.com/regions."
}

variable "appgateway_name" {
  description = "The name of the application gateway"
  default     = "cblt-appgateway"
}

variable "appgateway_sku_name" {
  description = "The SKU for the Appication Gateway to be created"
  default     = "Standard_Small"
}

variable "appgateway_tier" {
  description = "The tier of the application gateway. Small/Medium/Large. More details can be found at https://azure.microsoft.com/en-us/pricing/details/application-gateway/"
  default     = "Standard"
}

variable "appgateway_capacity" {
  description = "The capacity of application gateway to be created"
  default     = "1"
}

variable "appgateway_ipconfig_name" {
  description = "The IP Config Name for the Appication Gateway to be created"
  default     = "appgateway_ipconfig_name"
}

variable "appgateway_ipconfig_subnet_id" {
  description = "The Subnet ID for the Appication Gateway to be created"
}

variable "appgateway_frontend_port_name" {
  description = "The Frontend Port Name for the Appication Gateway to be created"
  default     = "appgateway_frontend_port_name"
}

variable "appgateway_frontend_ip_configuration_name" {
  description = "The Frontend IP configuration name for the Appication Gateway to be created"
  default     = "appgateway_frontend_ip_configuration_name"
}

variable "appgateway_frontend_public_ip_address_id" {
  description = "The Public IP address to the frontend for the Appication Gateway to be created"
  default     = "appgateway_frontend_ip_configuration_name"
}

variable "appgateway_backend_address_pool_name" {
  description = "The Backend Addres Pool Name for the Appication Gateway to be created"
  default     = "appgateway_backend_address_pool_name"
}

variable "appgateway_backend_http_setting_name" {
  description = "The Backend Http Settings Name for the Appication Gateway to be created"
  default     = "appgateway_http_setting_name"
}

variable "backend_http_cookie_based_affinity" {
  description = "The Backend Http cookie based affinity for the Appication Gateway to be created"
  default     = "Disabled"
}

variable "backend_http_protocol" {
  description = "The backend protocol for the Appication Gateway to be created"
  default     = "Http"
}

variable "http_listener_protocol" {
  description = "The Http Listener protocol for the Appication Gateway to be created"
  default     = "Http"
}

variable "appgateway_listener_name" {
  description = "The Listener Name for the Appication Gateway to be created"
  default     = "appgateway_listener_name"
}

variable "appgateway_request_routing_rule_name" {
  description = "The rule name to request routing for the Appication Gateway to be created"
  default     = "appgateway_request_routing_rule_name"
}

variable "request_routing_rule_type" {
  description = "The rule type to request routing for the Appication Gateway to be created"
  default     = "Basic"
}
