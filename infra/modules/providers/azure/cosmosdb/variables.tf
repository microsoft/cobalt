variable "service_plan_resource_group_name" {
  description = "Resource group name that the CosmosDB will be created in."
  type        = "string"
}

variable "cosmosdb_name" {
  description = "The name that CosmosDB will be created with."
  type        = "string"
}

variable "cosmosdb_kind" {
    description = "Determines the kind of CosmosDB to create. Can either be 'GlobalDocumentDB' or 'MongoDB'."
    type        = "string"
    default     = "GlobalDocumentDB"
}

variable "cosmosdb_automatic_failover" {
    description = "Determines if automatic failover is enabled for the created CosmosDB."
    default     = false
}

variable "consistency_level" {
    description = "The Consistency Level to use for this CosmosDB Account. Can be either 'BoundedStaleness', 'Eventual', 'Session', 'Strong' or 'ConsistentPrefix'."
    type        = "string"
    default     = "Session"
}

variable "primary_replica_location" {
    description = "The name of the Azure region to host replicated data."
    type        = "string"
}