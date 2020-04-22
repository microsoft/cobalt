output "properties" {
  description = "Properties of the deployed CosmosDB account."
  value = {
    cosmosdb = {
      id                 = azurerm_cosmosdb_account.cosmosdb.id
      endpoint           = azurerm_cosmosdb_account.cosmosdb.endpoint
      primary_master_key = azurerm_cosmosdb_account.cosmosdb.primary_master_key
      connection_strings = azurerm_cosmosdb_account.cosmosdb.connection_strings
    }
  }
  sensitive = true
}

# This output is required for proper integration testing.
output "resource_group_name" {
  description = "The resource group name for the CosmosDB account."
  value       = data.azurerm_resource_group.cosmosdb.name
}

# This output is required for proper integration testing.
output "account_name" {
  description = "The name of the CosmosDB account."
  value       = azurerm_cosmosdb_account.cosmosdb.name
}
