locals {
  secret_names = keys(var.secrets)
}

resource "azurerm_key_vault_secret" "secret" {
  count        = length(var.secrets)
  name         = local.secret_names[count.index]
  value        = var.secrets[local.secret_names[count.index]]
  key_vault_id = var.keyvault_id
}
