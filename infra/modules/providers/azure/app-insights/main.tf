module "azure-provider" {
    source = "../provider"
}

resource "azurerm_resource_group" "appinsights" {
  name     = "${var.resource_group_name}"
  location = "${var.resource_group_location}"
  tags     = "${var.resource_tags}"
}

resource "azurerm_application_insights" "appinsights" {
  name                = "${var.appinsights_name}"
  resource_group_name = "${azurerm_resource_group.appinsights.name}"
  location            = "${azurerm_resource_group.appinsights.location}"
  application_type    = "${var.appinsights_application_type}"
  tags                = "${var.resource_tags}"
}
