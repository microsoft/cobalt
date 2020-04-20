# Required inputs

variable "name" {
  description = "The name of the Redis instance. Changing this forces a new resource to be created as this should be a globally unique name."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group. TIP: Redis performs better when this is located in the same region as the app service intended for redis."
  type        = string
}

# Basic, Standard and Premimum Tier Inputs (optional)

variable "capacity" {
  description = "The size of the Redis cache to deploy. When premium account is enabled with clusters, the true capacity of the account cache is capacity * cache_shard_count"
  type        = number
  default     = 1
}

variable "sku_name" {
  description = "The Azure Cache for Redis pricing tier. Possible values are Basic, Standard and Premium. Azure currently charges by the minute for all pricing tiers."
  type        = string
  default     = "Standard"
}

variable "minimum_tls_version" {
  description = "The minimum TLS version."
  type        = string
  default     = "1.2"
}

# Standard & Premium Tier Inputs (optional)

variable "memory_features" {
  description = "Configures memory management for standard & premium tier accounts. All number values are in megabytes. maxmemory_policy_cfg property controls how Redis will select what to remove when maxmemory is reached."
  type = object({
    maxmemory_reserved              = number
    maxmemory_delta                 = number
    maxmemory_policy                = string
    maxfragmentationmemory_reserved = number
  })
  default = {
    maxmemory_reserved              = 50
    maxmemory_delta                 = 50
    maxmemory_policy                = "volatile-lru"
    maxfragmentationmemory_reserved = 50
  }
}

# Distinct Premium Tier Inputs (optional)

# We want to be explicit when enabling clustering due to its impact on pricing.
variable "premium_tier_config" {
  description = "Configures the weekly schedule for server patching (Patch Window lasts for 5 hours). Also enables a single cluster for premium tier and when enabled, the true cache capacity of a redis cluster is capacity * cache_shard_count. 10 is the maximum number of shards/nodes allowed."
  type = object({
    server_patch_day  = string
    server_patch_hour = number
    cache_shard_count = number
  })
  default = {
    server_patch_day  = "Friday"
    server_patch_hour = 17
    cache_shard_count = 0
  }
}

variable "resource_tags" {
  description = "Map of tags to apply to taggable resources in this module. By default the taggable resources are tagged with the name defined above and this map is merged in"
  type        = map(string)
  default     = {}
}