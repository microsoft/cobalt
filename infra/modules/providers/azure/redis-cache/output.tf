output "id" {
  description = "The azure redis cache ID."
  value       = azurerm_redis_cache.arc.id
}

output "hostname" {
  description = "The URL of the azure redis cache created."
  value       = azurerm_redis_cache.arc.hostname
}

output "ssl_port" {
  description = "The SSL Port of the Redis Instance."
  value       = azurerm_redis_cache.arc.ssl_port
}

output "name" {
  description = "The name of the Redis instance."
  value       = azurerm_redis_cache.arc.name
}

output "resource_group_name" {
  description = "The resource group name of the Redis instance."
  value       = azurerm_redis_cache.arc.resource_group_name
}

output "max_clients" {
  description = "Returns maximum number of allowed connected clients at same time based on current configuration."
  value       = azurerm_redis_cache.arc.redis_configuration[0].maxclients
}

output "maximum_cache_capacity" {
  description = "The maximum capacity of the cache."
  value       = azurerm_redis_cache.arc.capacity * var.premium_tier_config.cache_shard_count
}

output "primary_access_key" {
  description = "The Primary Access Key for the Redis Instance."
  value       = azurerm_redis_cache.arc.primary_access_key
}
