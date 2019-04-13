variable "prefix" {
  description = "(Required) The prefix used for all resources in this example"
}

variable "location" {
  description = "(Required) The Azure location where all resources in this example should be created"
}

variable "storage_account_replication_type" {
  description = "(Required) Defines the type of replication to use for this storage account. Valid options are LRS*, GRS, RAGRS and ZRS."
  default     = "LRS"
}