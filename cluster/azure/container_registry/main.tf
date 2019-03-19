module "azure-provider" {
    source = "../provider"
}

resource "azurerm_resource_group" "container_registry" {
  name     = "${var.resource_group_name}"
  location = "${var.location}"
}

resource "azurerm_container_registry" "container_registry" {
  name                = "${var.container_registry_name}"
  location            = "${azurerm_resource_group.container_registry.location}"
  resource_group_name = "${azurerm_resource_group.container_registry.name}"
  admin_enabled       = true
  sku {
    name = "${var.container_registry_sku}"
  }
}
