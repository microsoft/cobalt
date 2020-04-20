variable "resource_group_name" {
  description = "Resource group name that the CosmosDB will be created in."
  type        = string
}

variable "name" {
  description = "The name that CosmosDB will be created with."
  type        = string
}

variable "primary_replica_location" {
  description = "The name of the Azure region to host replicated data."
  type        = string
}

variable "kind" {
  description = "Determines the kind of CosmosDB to create. Can either be 'GlobalDocumentDB' or 'MongoDB'."
  type        = string
  default     = "GlobalDocumentDB"
}

variable "automatic_failover" {
  description = "Determines if automatic failover is enabled for the created CosmosDB."
  default     = false
}

variable "consistency_level" {
  description = "The Consistency Level to use for this CosmosDB Account. Can be either 'BoundedStaleness', 'Eventual', 'Session', 'Strong' or 'ConsistentPrefix'."
  type        = string
  default     = "Session"
}

variable "sql_collections" {
  description = "The list of cosmos collection names to create. Names must be unique per cosmos instance."
  type = list(object({
    name               = string
    database_name      = string
    partition_key_path = string
    throughput         = number
  }))
  default = []
}

variable "databases" {
  description = "The list of Cosmos DB SQL Databases."
  type = list(object({
    name       = string
    throughput = number
  }))
  default = []
}