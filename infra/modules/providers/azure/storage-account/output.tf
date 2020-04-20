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

output "id" {
  description = "The ID of the storage account."
  value       = azurerm_storage_account.main.id
}

output "name" {
  description = "The name of the storage account."
  value       = azurerm_storage_account.main.name
}

output "primary_access_key" {
  description = "The primary access key for the storage account."
  value       = azurerm_storage_account.main.primary_access_key
}

output "containers" {
  description = "Map of containers."
  value = {
    for c in azurerm_storage_container.main :
    c.name => {
      id   = c.id
      name = c.name
    }
  }
}

output "tenant_id" {
  description = "The tenant ID for the Service Principal of this storage account."
  value       = azurerm_storage_account.main.identity.0.tenant_id
}

output "managed_identities_id" {
  description = "The principal ID generated from enabling a Managed Identity with this storage account."
  value       = azurerm_storage_account.main.identity.0.principal_id
}

# This output is required for proper integration testing.
output "resource_group_name" {
  description = "The resource group name for the Storage Account."
  value       = data.azurerm_resource_group.main.name
}
