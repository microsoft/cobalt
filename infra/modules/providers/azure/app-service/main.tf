resource "azurerm_resource_group" "appsvc" {
  name     = "${var.resource_group_name}"
  location = "${var.resource_group_location}"
}

resource "azurerm_app_service_plan" "appsvc" {
  name                = "${var.svcplan_name}"
  location            = "${azurerm_resource_group.appsvc.location}"
  resource_group_name = "${azurerm_resource_group.appsvc.name}"
  kind                = "${var.svcplan_kind}"

  sku {
    tier = "${var.svcplan_tier}"
    size = "${var.svcplan_size}"
  }
}

resource "azurerm_app_service" "appsvc" {
  name                = "${var.appsvc_name}"
  location            = "${azurerm_resource_group.appsvc.location}"
  resource_group_name = "${azurerm_resource_group.appsvc.name}"
  app_service_plan_id = "${azurerm_app_service_plan.appsvc.id}"
}
