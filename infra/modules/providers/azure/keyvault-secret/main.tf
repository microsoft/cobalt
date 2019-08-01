resource "azurerm_key_vault_secret" "secret" {
  count        = length(var.secrets)
  name         = var.secrets[count.index].name
  value        = var.secrets[count.index].value
  key_vault_id = var.keyvault_id
}
