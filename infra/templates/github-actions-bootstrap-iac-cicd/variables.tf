variable "owner" {
  type        = string
  description = "The Github repository owner"
}

variable "token" {
  type        = string
  description = "The Github personal access token"
  sensitive   = true
}

variable "location" {
  type        = string
  description = "Location in which to provision Azure resources"
}

variable "prefix" {
  type        = string
  description = "Naming prefix for resources in Azure"
}

variable "repository" {
  type        = string
  description = "The Github repository"
}
