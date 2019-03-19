provider "null" {
    version = "~>2.0.0"
}

data "azuread_service_principal" "user" {
  application_id = "${var.service_principal_id}"
}

resource "azurerm_role_assignment" "user" {
  principal_id         = "${data.azuread_service_principal.user.id}"
  role_definition_name = "${var.user_role_assignment_role}"
  scope                = "/subscriptions/${var.subscription_id}/resourcegroups/${var.resource_group_name}/providers/Microsoft.KeyVault/vaults/${var.keyvault_name}"
}

resource "azurerm_key_vault_access_policy" "user" {
  vault_name          = "${var.keyvault_name}"
  resource_group_name = "${var.resource_group_name}"

  tenant_id = "${var.tenant_id}"
  object_id = "${data.azuread_service_principal.user.id}"

  key_permissions = "${var.user_keyvault_key_permissions}"
  secret_permissions = "${var.user_keyvault_secret_permissions}"
  certificate_permissions = "${var.user_keyvault_certificate_permissions}"
}
