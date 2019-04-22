resource "random_id" "remotestate_account_name" {
  byte_length = 6
  keepers {
    sa_account_ref = 1
  }
}

resource "azurerm_resource_group" "svcplan" {
  name     = "${var.resource_group_name == "" ? "${local.name}-cobalt-rg" : "${var.resource_group_name}"}"
  location = "${var.resource_group_location}"
  tags     = "${merge(map("Name", "${local.name}"), var.resource_tags)}"
}

resource "azurerm_app_service_plan" "svcplan" {
  name                = "${var.svcplan_name == "" ? "${local.name}-cobalt-svcplan" : "${var.svcplan_name}"}"
  location            = "${azurerm_resource_group.svcplan.location}"
  resource_group_name = "${azurerm_resource_group.svcplan.name}"
  kind                = "${var.svcplan_kind}"
  tags                = "${merge(map("Name", "${local.name}"), var.resource_tags)}"
  reserved            = "${var.svcplan_kind == "Linux" ? true : "${var.svcplan_reserved}"}"

  sku {
    tier      = "${var.svcplan_tier}"
    size      = "${var.svcplan_size}"
    capacity  = "${var.svcplan_capacity}"
  }
}

resource "azurerm_app_service" "appsvc" {
  name                = "${var.appsvc_name == "" ? "${local.name}-cobalt-appsvc" : "${var.appsvc_name}"}"
  location            = "${azurerm_resource_group.svcplan.location}"
  resource_group_name = "${azurerm_resource_group.svcplan.name}"
  app_service_plan_id = "${azurerm_app_service_plan.svcplan.id}"
  tags                = "${merge(map("Name", "${local.name}"), var.resource_tags)}"
}

resource "azurerm_public_ip" "appsvc" {
  name                = "${var.publicip_name == "" ? "${local.name}-cobalt-publicip" : "${var.publicip_name}"}"
  resource_group_name = "${azurerm_resource_group.svcplan.name}"
  location            = "${azurerm_resource_group.svcplan.location}"
  sku                 = "${var.publicip_sku}"
  allocation_method   = "${var.pubip_alloc_method}"
  tags                = "${merge(map("Name", "${local.name}"), var.resource_tags)}"
}

resource "azurerm_lb" "appsvc" {
  name                = "${var.lb_name == "" ? "${local.name}-cobalt-loadbalancer" : "${var.lb_name}"}"
  location            = "${azurerm_resource_group.svcplan.location}"
  resource_group_name = "${azurerm_resource_group.svcplan.name}"
  tags                = "${merge(map("Name", "${local.name}"), var.resource_tags)}"

  frontend_ip_configuration {
    name                 = "${azurerm_public_ip.appsvc.name}"
    public_ip_address_id = "${azurerm_public_ip.appsvc.id}"
  }
}
