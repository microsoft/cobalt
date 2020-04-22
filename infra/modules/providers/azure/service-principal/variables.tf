variable "role_name" {
  description = "The name of the role definition to assign a service principle too."
  type        = string
}

variable "role_scopes" {
  description = "The scopes at which the Role Assignment applies too, such as [/subscriptions/0b1f6471-1bf0-4dda-aec3-111122223333]"
  type        = list(string)
}

variable "create_for_rbac" {
  description = "Create a new Service Principle"
  type        = bool
  default     = false
}

variable "display_name" {
  description = "Display name of the AD application"
  type        = string
  default     = ""
}

variable "object_id" {
  description = "Object Id of the service principle to assign a role"
  type        = string
  default     = ""
}

variable "sp_pwd_end_date_relative" {
  description = "A relative duration for which the Password is valid until"
  type        = string
  default     = "17520h" #2 Years
}