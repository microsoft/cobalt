resource "azurerm_resource_group" "rg_core" {
  name = "${var.resource_group_name}"
  location = "${var.resource_group_location}"
}
