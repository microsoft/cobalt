module "azure-provider" {
  source = "../provider"
}

data "azurerm_resource_group" "cosmosdb" {
  name = var.resource_group_name
}

locals {
  offer_type                         = "Standard"
  ip_range_filter_Allow_Azure_Portal = "0.0.0.0"
}

resource "azurerm_cosmosdb_account" "cosmosdb" {
  name                = var.account_name
  location            = data.azurerm_resource_group.cosmosdb.location
  resource_group_name = data.azurerm_resource_group.cosmosdb.name
  offer_type          = local.offer_type
  kind                = var.kind

  enable_automatic_failover         = var.automatic_failover
  is_virtual_network_filter_enabled = true
  ip_range_filter                   = local.ip_range_filter_Allow_Azure_Portal

  virtual_network_rule {
    id = var.vnet_subnet_id
  }

  consistency_policy {
    consistency_level = var.consistency_level
  }

  geo_location {
    location          = var.primary_replica_location
    failover_priority = 0
  }
}

resource "azurerm_cosmosdb_sql_database" "cosmos_dbs" {
  depends_on          = [azurerm_cosmosdb_account.cosmosdb]
  count               = length(var.databases)
  name                = var.databases[count.index].name
  account_name        = var.account_name
  resource_group_name = data.azurerm_resource_group.cosmosdb.name
  throughput          = var.databases[count.index].throughput
}

resource "azurerm_cosmosdb_sql_container" "cosmos_collections" {
  depends_on          = [azurerm_cosmosdb_sql_database.cosmos_dbs]
  count               = length(var.sql_collections)
  name                = var.sql_collections[count.index].name
  account_name        = var.account_name
  database_name       = var.sql_collections[count.index].database_name
  resource_group_name = data.azurerm_resource_group.cosmosdb.name
  partition_key_path  = var.sql_collections[count.index].partition_key_path
  throughput          = var.sql_collections[count.index].throughput
}
