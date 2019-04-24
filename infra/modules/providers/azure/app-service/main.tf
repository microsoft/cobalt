resource "azurerm_resource_group" "appsvc" {
  name     = "${var.resource_group_name}"
  location = "${var.resource_group_location}"
  tags     = "${var.resource_tags}"
}

resource "azurerm_app_service" "appsvc" {
  name                = "${var.app_service_name}"
  location            = "${azurerm_resource_group.appsvc.location}"
  resource_group_name = "${azurerm_resource_group.appsvc.name}"
  app_service_plan_id = "${var.app_service_plan_id}"
  tags                = "${var.resource_tags}"
}
