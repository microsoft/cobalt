variable "create_for_rbac" {
  description = "Create a new Service Principle"
  type        = "string"
  default     = "true"
}

variable "display_name" {
  description = "Display name of the AD application"
  type        = "string"
}

variable "object_id" {
  description = "Object Id of the service principle to assign a role"
  type        = "string"
  default     = ""
}

variable "role_name" {
  description = "The name of the role definition to assign a service principle too."
  type        = "string"
}

variable "role_scope" {
  description = "The scope at which the Role Assignment applies too, such as /subscriptions/0b1f6471-1bf0-4dda-aec3-111122223333"
  type        = "string"
}
