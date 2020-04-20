variable "elasticsearch" {
  description = "Settings for defining a cluster"
  type = object({
    version = string
    cluster_topology = object({
      memory_per_node     = number
      node_count_per_zone = number
      zone_count          = number
      node_type = object({
        data   = bool
        ingest = bool
        master = bool
        ml     = bool
      })
    })
  })
}

variable "name" {
  description = "The name of the deployment"
  type        = string
}

variable "coordinator_url" {
  description = "The coordinator URL"
  type        = string
}

variable "auth_token" {
  description = "Authentication token"
  type        = string
}

variable "auth_type" {
  description = "Type of auth to use. Options are 'ApiKey' or 'Basic'"
  type        = string
  default     = "ApiKey"
}