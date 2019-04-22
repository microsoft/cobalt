# Azure Container Registry

variable "acr_enabled" {
  type    = "string"
  default = "true"
}

# Resource Group

variable "resource_group_name" {
  type = "string"
}

variable "resource_group_location" {
  type = "string"
}

# Service Principal

variable "service_principal_id" {
  type = "string"
}

variable "service_principal_secret" {
  type = "string"
}

# vnet

variable "vnet_name" {
  type = "string"
}

variable "cluster_name" {
  type = "string"
}

variable "service_cidr" {
  default     = "10.0.0.0/16"
  description = "Used to assign internal services in the AKS cluster an IP address. This IP address range should be an address space that isn't in use elsewhere in your network environment. This includes any on-premises network ranges if you connect, or plan to connect, your Azure virtual networks using Express Route or a Site-to-Site VPN connections."
  type        = "string"
}

variable "dns_ip" {
  default     = "10.0.0.10"
  description = "should be the .10 address of your service IP address range"
  type        = "string"
}

variable "docker_cidr" {
  default     = "172.17.0.1/16"
  description = "IP address (in CIDR notation) used as the Docker bridge IP address on nodes. Default of 172.17.0.1/16."
}

variable "address_space" {
  description = "The address space that is used by the virtual network."
  default     = "10.10.0.0/16"
}

variable "subnet_prefixes" {
  description = "The address prefix to use for the subnet."
  default     = ["10.10.1.0/24"]
}

# Traffic Manager Variables
variable "traffic_manager_profile_name" {
  description = "Profile name for the trafic manager"
}

variable "traffic_manager_dns_name" {
  description = "DNS name that will be given to the traffic manager"
}

variable "resource_location" {
  description = "Traffic manager resource location"
}

variable "traffic_manager_resource_group_name" {
  description = "Resource manager that will be used to group the traffic manager"
}

variable "public_ip_name" {
  description = "IP address that will be given to the traffic manager"
}

variable "endpoint_name" {
  description = "Name of the endpoint that will be associate to the traffic manager"
}

variable "ip_address_out_filename" {
  description = "File that will be used to report the IP address of the traffic manager"
}
