module "azure-provider" {
  source = "../provider"
}

data "azurerm_resource_group" "kv" {
  name = "${var.resource_group_name}"
}

data "azurerm_client_config" "sp" {}

resource "azurerm_key_vault" "keyvault" {
  name                        = "${var.keyvault_name}"
  location                    = "${data.azurerm_resource_group.keyvault.location}"
  resource_group_name         = "${data.azurerm_resource_group.keyvault.name}"
  tenant_id                   = "${data.azurerm_client_config.sp.tenant_id}"
  object_id                   = "${data.azurerm_client_config.sp.client_id}"

  sku {
      name                    = "${var.keyvault_sku}"
  }

  access_policy {
      tenant_id               = "${data.azurerm_client_config.sp.tenant_id}"
      object_id               = "${data.azurerm_client_config.sp.client_id}"
      key_permissions         = "${var.keyvault_key_permissions}"
      secret_permissions      = "${var.keyvault_secret_permissions}"
      certificate_permissions = "${var.keyvault_certificate_permissions}"
  }
}
