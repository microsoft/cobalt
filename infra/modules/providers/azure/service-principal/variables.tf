variable "create_for_rbac" {
  description = "Create a new Service Principle"
  type = "string"
  default = "true"
}

variable "service_principle_object_id" {
  description = "Object Id of the service principle to assign a role"
  type = "string"
  default = ""
}

variable "role_name" {
    description = "The name of the to assign a service principle to"
    type = "string"
}


