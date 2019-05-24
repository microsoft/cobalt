output "cosmosdb_endpoint" {
  description = "The endpoint used to connect to the CosmosDB account."
  value       = "${azurerm_cosmosdb_account.cosmosdb.endpoint}"
}

output "cosmosdb_primary_master_key" {
  description = "The Primary master key for the CosmosDB Account."
  value       = "${azurerm_cosmosdb_account.cosmosdb.primary_master_key}"
  sensitive   = true
}

output "cosmosdb_connection_strings" {
  description = "A list of connection strings available for this CosmosDB account."
  value       = "${azurerm_cosmosdb_account.cosmosdb.connection_strings}"
}