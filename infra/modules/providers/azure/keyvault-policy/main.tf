resource "azurerm_key_vault_access_policy" "keyvault" {
  count        = length(var.object_ids)
  key_vault_id = var.vault_id

  tenant_id = var.tenant_id
  object_id = var.object_ids[count.index]

  key_permissions         = var.key_permissions
  secret_permissions      = var.secret_permissions
  certificate_permissions = var.certificate_permissions
}

