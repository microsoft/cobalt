output "cosmosdb_endpoint" {
  description = "The endpoint used to connect to the CosmosDB account."
  value       = "${azurerm_cosmosdb_account.cosmosdb.endpoint}"
}

output "cosmosdb_primary_master_key" {
    description = "The Primary master key for the CosmosDB Account."
    value = "${azurerm_cosmosdb_account.cosmosdb.primary_master_key}"
}