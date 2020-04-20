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
