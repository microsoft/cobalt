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
