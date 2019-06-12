
output "storage_account_id" {
  description = "The ID of the storage account."
  value       = "${azurerm_storage_account.sa.id}"
}

output "storage_account_msi_object_id" {
  description = "The principal ID generated for enabling a Managed Identity with the Service Principal of this Storage Account."
  value       = "${azurerm_storage_account.sa.identity.0.principal_id}"
}

output "storage_account_tenant_id" {
  description = "The tenant ID for the Service Principal of this Storage Account."
  value       = "${azurerm_storage_container.sa.id}"
}

output "storage_container_id" {
  description = "The id of the storage container from the storage-account module."
  value       = "${azurerm_storage_container.sa.id}"
}

output "storage_container_properties" {
  description = "Map of additional properties associated with the storage container."
  value       = "${azurerm_storage_container.sa.properties}"
}
