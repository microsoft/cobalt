module "resource_group" {
  source = "../resource_group"
  resource_group_location            = "${var.resource_group_location}"
  resource_group_name                = "${var.resource_group_name}"
 }

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "keyvault" {
  name                = "${var.keyvault_name}"
  location            = "${var.resource_group_location}"
  resource_group_name = "${var.resource_group_name}"
  tenant_id           = "${data.azurerm_client_config.current.tenant_id}"
  depends_on          = ["module.resource_group"]

  sku {
    name = "${var.keyvault_sku}"
  }

  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }
}
