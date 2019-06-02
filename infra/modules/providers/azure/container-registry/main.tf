data "azurerm_resource_group" "acr" {
  name = "${var.resource_group_name}"
}

resource "azurerm_container_registry" "acr" {
  name                     = "${var.acr_name}"
  resource_group_name      = "${data.azurerm_resource_group.acr.name}"
  location                 = "${data.azurerm_resource_group.acr.location}"
  sku                      = "${var.acr_sku}"
  admin_enabled            = "${var.acr_admin_enabled}"
}