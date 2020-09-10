variable "group_path" {
  type        = string
  description = "The group that secrets should be provisioned into"
}

variable "location" {
  type        = string
  description = "Location in which to provision Azure resources"
}

variable "gitlab_terraform_project_path" {
  type        = string
  description = "Path of project in gitlab that houses infrastructure templates"
}

variable "prefix" {
  type        = string
  description = "Naming prefix for resources in Azure"
}
