data "azurerm_resource_group" "apimgmt" {
  name      = "${var.service_plan_resource_group_name}"
}
resource "azurerm_api_management" "apimgmt" {
  name                = "${var.apimgmt_name}"
  location            = "${data.azurerm_resource_group.apimgmt.location}"
  resource_group_name = "${data.azurerm_resource_group.apimgmt.name}"
  publisher_name      = "${var.apimgmt_pub_name}"
  publisher_email     = "${var.apimgmt_pub_email}"
  tags                = "${var.resource_tags}"

  sku {
    name     = "${var.apimgmt_sku}"
    capacity = "${var.apimgmt_capacity}"
  }
}

resource "azurerm_api_management_api" "apimgmt" {
  name                = "${var.api_name}-${count.index}"
  resource_group_name = "${data.azurerm_resource_group.apimgmt.name}"
  api_management_name = "${azurerm_api_management.apimgmt.name}"
  revision            = "${var.revision}"
  display_name        = "${var.display_name} ${count.index}"
  path                = "${var.path}-${count.index}"
  protocols           = "${var.protocols}"
  service_url         = "https://${var.service_url[0]}"
  # TODO: count               = "${length(var.service_url)}"
}

resource "azurerm_api_management_logger" "apimgmt" {
  name                = "${var.apimgmt_logger_name}"
  api_management_name = "${azurerm_api_management.apimgmt.name}"
  resource_group_name = "${data.azurerm_resource_group.apimgmt.name}"

  application_insights {
    instrumentation_key = "${var.appinsghts_instrumentation_key}"
  }
}