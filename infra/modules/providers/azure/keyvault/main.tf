module "azure-provider" {
  source = "../provider"
}

data "azurerm_resource_group" "kv" {
  name = "${var.resource_group_name}"
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "keyvault" {
  name                = "${var.keyvault_name}"
  location            = "${data.azurerm_resource_group.kv.location}"
  resource_group_name = "${data.azurerm_resource_group.kv.name}"
  tenant_id           = "${data.azurerm_client_config.current.tenant_id}"

  sku {
    name = "${var.keyvault_sku}"
  }

  access_policy {
    tenant_id               = "${data.azurerm_client_config.current.tenant_id}"
    object_id               = "${data.azurerm_client_config.current.service_principal_object_id}"
    key_permissions         = "${var.keyvault_key_permissions}"
    secret_permissions      = "${var.keyvault_secret_permissions}"
    certificate_permissions = "${var.keyvault_certificate_permissions}"
  }

  tags = "${var.resource_tags}"
}
