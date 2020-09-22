
output "backend-state-account-name" {
  value = azurerm_storage_account.ci.name
}

output "backend-state-account-key" {
  value = azurerm_storage_account.ci.primary_access_key
}

output "backend-state-bootstrap-container-name" {
  value = azurerm_storage_container.tfstate.name
}
