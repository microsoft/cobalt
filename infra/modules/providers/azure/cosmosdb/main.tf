//  Copyright © Microsoft Corporation
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

data "azurerm_resource_group" "cosmosdb" {
  name = var.resource_group_name
}

resource "azurerm_cosmosdb_account" "cosmosdb" {
  name                = var.name
  location            = data.azurerm_resource_group.cosmosdb.location
  resource_group_name = data.azurerm_resource_group.cosmosdb.name
  offer_type          = "Standard"
  kind                = var.kind

  enable_automatic_failover = var.automatic_failover

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
  account_name        = var.name
  resource_group_name = data.azurerm_resource_group.cosmosdb.name
  throughput          = var.databases[count.index].throughput
}

resource "azurerm_cosmosdb_sql_container" "cosmos_collections" {
  depends_on          = [azurerm_cosmosdb_sql_database.cosmos_dbs]
  count               = length(var.sql_collections)
  name                = var.sql_collections[count.index].name
  account_name        = var.name
  database_name       = var.sql_collections[count.index].database_name
  resource_group_name = data.azurerm_resource_group.cosmosdb.name
  partition_key_path  = var.sql_collections[count.index].partition_key_path
  throughput          = var.sql_collections[count.index].throughput
}
