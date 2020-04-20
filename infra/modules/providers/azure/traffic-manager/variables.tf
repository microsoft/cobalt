variable "traffic_manager_profile_name" {
  type = string
}

variable "public_ip_name" {
  type = string
}

variable "endpoint_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "traffic_manager_dns_name" {
  type = string
}

variable "traffic_manager_monitor_protocol" {
  type    = string
  default = "https"
}

variable "traffic_manager_monitor_port" {
  type    = number
  default = 443
}

variable "tags" {
  description = "The tags to associate with the public ip address."
  type        = map(string)

  default = {
    tag1 = ""
    tag2 = ""
  }
}

