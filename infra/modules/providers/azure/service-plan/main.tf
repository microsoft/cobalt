data "azurerm_resource_group" "svcplan" {
  name = "${var.resource_group_name}"
}

resource "azurerm_app_service_plan" "svcplan" {
  name                = "${var.service_plan_name}"
  location            = "${data.azurerm_resource_group.svcplan.location}"
  resource_group_name = "${var.resource_group_name}"
  kind                = "${var.service_plan_kind}"
  tags                = "${var.resource_tags}"
  reserved            = "${var.service_plan_kind == "Linux" ? true : "${var.service_plan_reserved}"}"

  sku {
    tier     = "${var.service_plan_tier}"
    size     = "${var.service_plan_size}"
    capacity = "${var.service_plan_capacity}"
  }
}
