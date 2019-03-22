module "azure-provider" {
    source = "../provider"
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault_access_policy" "keyvault" {
  vault_name          = "${var.keyvault_name}"
  resource_group_name = "${var.resource_group_name}"

  tenant_id = "${data.azurerm_client_config.current.tenant_id}"
  object_id = "${var.object_id}"

  key_permissions = "${var.key_permissions}"
  secret_permissions = "${var.secret_permissions}"
}