resource "azurerm_resource_group" "svcplan" {
  name     = "${var.resource_group_name}"
  location = "${var.resource_group_location}"
  tags     = "${var.resource_tags}"
}

resource "azurerm_app_service_plan" "svcplan" {
  name                = "${var.service_plan_name}"
  location            = "${azurerm_resource_group.svcplan.location}"
  resource_group_name = "${azurerm_resource_group.svcplan.name}"
  kind                = "${var.service_plan_kind}"
  tags                = "${var.resource_tags}"
  reserved            = "${var.service_plan_kind == "Linux" ? true : "${var.service_plan_reserved}"}"

  sku {
    tier      = "${var.service_plan_tier}"
    size      = "${var.service_plan_size}"
    capacity  = "${var.service_plan_capacity}"
  }
}

resource "azurerm_app_service" "appsvc" {
  name                = "${var.app_service_name}"
  location            = "${azurerm_resource_group.svcplan.location}"
  resource_group_name = "${azurerm_resource_group.svcplan.name}"
  app_service_plan_id = "${azurerm_app_service_plan.svcplan.id}"
  tags                = "${var.resource_tags}"
}

resource "azurerm_public_ip" "appsvc" {
  name                = "${var.public_ip_name}"
  resource_group_name = "${azurerm_resource_group.svcplan.name}"
  location            = "${azurerm_resource_group.svcplan.location}"
  sku                 = "${var.public_ip_sku}"
  allocation_method   = "${var.public_ip_alloc_method}"
  tags                = "${var.resource_tags}"
}

resource "azurerm_lb" "appsvc" {
  name                = "${var.load_balancer_name}"
  location            = "${azurerm_resource_group.svcplan.location}"
  resource_group_name = "${azurerm_resource_group.svcplan.name}"
  tags                = "${var.resource_tags}"

  frontend_ip_configuration {
    name                 = "${azurerm_public_ip.appsvc.name}"
    public_ip_address_id = "${azurerm_public_ip.appsvc.id}"
  }
}
