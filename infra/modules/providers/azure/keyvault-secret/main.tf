locals {
  secret_names = keys(var.secrets)
}

resource "azurerm_key_vault_secret" "secret" {
  count        = length(var.secrets)
  name         = local.secret_names[count.index]
  value        = var.secrets[local.secret_names[count.index]]
  key_vault_id = var.keyvault_id
}

data "azurerm_key_vault_secret" "secrets" {
  count        = length(var.secrets)
  depends_on   = [azurerm_key_vault_secret.secret]
  name         = local.secret_names[count.index]
  key_vault_id = var.keyvault_id
}
