output "keyvault_secret_ids" {
  description = "The id of the Keyvault secret"
  value       = azurerm_key_vault_secret.secret.*.id
}

output "keyvault_secret_versions" {
  description = "The version of the keyvault secret"
  value       = azurerm_key_vault_secret.secret.*.version
}
