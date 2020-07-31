variable "resource_group_name" {
  description = "Name of the Resource Group in which the Machine Learning Workspace should exist. Changing this forces a new resource to be created"
  type        = string
}
variable "name" {
  description = "Name of the Machine Learning Workspace. Changing this forces a new resource to be created"
  type        = string
}
variable "application_insights_id" {
  description = "Name of the Application Insights associated with this Machine Learning Workspace. Changing this forces a new resource to be created"
  type        = string
}
variable "key_vault_id" {
  description = "Name of key vault associated with this Machine Learning Workspace. Changing this forces a new resource to be created"
  type        = string
}
variable "storage_account_id" {
  description = "The name of the Storage Account associated with this Machine Learning Workspace. Changing this forces a new resource to be created"
  type        = string
}
variable "sku_name" {
  description = "SKU/edition of the Machine Learning Workspace"
  type        = string
  default     = "Enterprise"
}
