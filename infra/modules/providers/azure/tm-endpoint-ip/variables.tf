variable "traffic_manager_profile_name" {
  type = "string"
}

variable "public_ip_name" {
  type = "string"
}

variable "endpoint_name" {
  type = "string"
}

variable "resource_group_name" {
  type = "string"
}

variable "tags" {
  description = "The tags to associate with the public ip address."
  type        = "map"

  default = {
    tag1 = ""
    tag2 = ""
  }
}
