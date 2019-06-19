variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
}

variable "resource_group_location" {
  description = "The location of the resource group."
  type        = string
}

variable "account_name" {
  description = "The name of the storage account service."
  type        = string
}

variable "storage_container_name" {
  description = "The name of the storage container. Must be unique under the storage account."
  type        = string
}

variable "performance_tier" {
  description = "Determines the level of performance required."
  type        = string
  default     = "Standard"
}

variable "replication_type" {
  description = "Defines the type of replication to use for this storage account. Valid options are LRS*, GRS, RAGRS and ZRS."
  type        = string
  default     = "LRS"
}

variable "kind" {
  description = "Storage account types that determine available features and pricing of Azure Storage. Use StorageV2 when possible."
  type        = string
  default     = "StorageV2"
}

variable "https" {
  description = "Boolean flag which forces HTTPS in order to ensure secure connections."
  type        = string
  default     = "true"
}

variable "encryption_source" {
  description = "Determines the source that will manage encryption for the storage account. Valid options are Microsoft.Storage and Microsoft.Keyvault."
  type        = string
  default     = "Microsoft.Storage"
}


variable "existing_sp_object_id" {
  description = "The azure ad identity of the service principal granted the right to perform operations on storage containers."
  type        = string
  default     = ""
}

variable "storage_role_definition_name" {
  description = "The predefined name of the role definition a service principal will use to perform operations on storage containers. Defaults to a non-custom built-in system role definition."
  type        = string
  default     = "reader"
}