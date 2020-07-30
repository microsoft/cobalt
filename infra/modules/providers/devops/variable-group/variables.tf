variable "project_name" {
  type        = string
  description = ""
}

variable "variable_group_name" {
  type        = string
  description = ""
}


variable "variable_group_description" {
  type        = string
  description = ""
  default     = " "
}

variable "allow_access" {
  type        = bool
  description = ""
  default     = true
}

variable "variables" {
  type = list(object({
    name      = string
    value     = string
    is_secret = bool
  }))
}

