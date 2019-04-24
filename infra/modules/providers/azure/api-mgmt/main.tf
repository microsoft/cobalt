module "azure-provider" {
    source = "../provider"
}

resource "azurerm_resource_group" "apimgmt" {
  name     = "${var.resource_group_name}"
  location = "${var.resource_group_location}"
  tags     = "${var.resource_tags}"
}

resource "azurerm_api_management" "apimgmt" {
  name                = "${var.apimgmt_name}"
  location            = "${azurerm_resource_group.apimgmt.location}"
  resource_group_name = "${azurerm_resource_group.apimgmt.name}"
  publisher_name      = "${var.apimgmt_pub_name}"
  publisher_email     = "${var.apimgmt_pub_email}"
  tags                = "${var.resource_tags}"

  sku {
    name     = "${var.apimgmt_sku}"
    capacity = "${var.apimgmt_capacity}"
  }
}

resource "azurerm_application_insights" "apimgmt" {
  name                = "${var.appinsights_name}"
  resource_group_name = "${azurerm_resource_group.apimgmt.name}"
  location            = "${azurerm_resource_group.apimgmt.location}"
  application_type    = "${var.appinsights_application_type}"
  tags                = "${var.resource_tags}"
}