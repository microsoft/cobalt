data "azurerm_resource_group" "container_registry" {
  name = "${var.resource_group_name}"
}

resource "azurerm_container_registry" "container_registry" {
  name                = "${var.container_registry_name}"
  resource_group_name = "${data.azurerm_resource_group.container_registry.name}"
  location            = "${data.azurerm_resource_group.container_registry.location}"
  sku                 = "${var.container_registry_sku}"
  admin_enabled       = "${var.container_registry_admin_enabled}"
  tags                = "${var.container_registry_tags}"
}
