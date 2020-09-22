
variable "environment_name" {
  type        = string
  description = "The name of the environment"
}

variable "location" {
  type        = string
  description = "The region to deploy the environment to"
}

variable "subscription_id" {
  type        = string
  description = "The subscription id to create service principals in"
}

variable "acr_id" {
  type        = string
  description = "ACR ID to use for kubernetes deployments"
}

variable "backend_storage_account_name" {
  type        = string
  description = "the name of the storage account in which to provision a tf state container"
}

variable "gitlab_terraform_project_path" {
  type        = string
  description = "Path of project in gitlab that houses infrastructure templates"
}

variable "prefix" {
  type        = string
  description = "Naming prefix for resources in Azure"
}
