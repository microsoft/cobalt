resource "azurerm_resource_group" "acr" {
  name = "${var.resource_group_name}"
  location = "${var.resource_group_location}"
}

resource "azurerm_container_registry" "acr" {
  name                     = "${var.acr_name}"
  resource_group_name      = "${azurerm_resource_group.acr.name}"
  location                 = "${azurerm_resource_group.acr.location}"
  sku                      = "${var.acr_sku}"
  admin_enabled            = "${var.acr_admin_enabled}"
}