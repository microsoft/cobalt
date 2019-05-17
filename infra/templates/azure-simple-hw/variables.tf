variable "prefix" {
  description = "The prefix used for all resources in this example"
}

variable "location" {
  description = "The Azure location where all resources in this example should be created"
}

variable "storage_account_replication_type" {
  description = "Defines the type of replication to use for this storage account. Valid options are LRS*, GRS, RAGRS and ZRS."
  default     = "LRS"
}

variable "app_service_linux_container_command" {
  description = "Defines the exec command for linux based container app services."
  default     = "DOCKER|appsvcsample/static-site:latest"
}
