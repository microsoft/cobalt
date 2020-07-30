variable "project_name" {
  type        = string
  description = "Azure DevOps project name that will be used to add the new variable group"
}

variable "variable_group_name" {
  type        = string
  description = "Azure DevOps Variable Group Name to be created"
}


variable "variable_group_description" {
  type        = string
  description = ""
  default     = "An optional field to add description about the variable group"
}

variable "allow_access" {
  type        = bool
  description = "A flag to detirmine if the variable group will allow to access all pipelines or not"
  default     = true
}

variable "variables" {
  type = list(object({
    name      = string
    value     = string
    is_secret = bool
  }))
}

