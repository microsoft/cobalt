resource "azurerm_key_vault_secret" "acr_sp_pwd_secret" {
  name         = "acr-service-principal-password"
  value        = module.acr_service_principal_acrpull.service_principal_password
  key_vault_id = module.keyvault.keyvault_id

  lifecycle {
    ignore_changes = ["value"]
  }
}

resource "azurerm_key_vault_secret" "app_svc_sp_pwd_secret" {
  name         = "app-service-principal-password"
  value        = module.app_service_principal_contributor.service_principal_password
  key_vault_id = module.keyvault.keyvault_id

  lifecycle {
    ignore_changes = ["value"]
  }
}