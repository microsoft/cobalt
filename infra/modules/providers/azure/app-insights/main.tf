data "azurerm_resource_group" "appinsights" {
  name = var.service_plan_resource_group_name
}

resource "azurerm_application_insights" "appinsights" {
  name                = var.appinsights_name
  resource_group_name = data.azurerm_resource_group.appinsights.name
  location            = data.azurerm_resource_group.appinsights.location
  application_type    = var.appinsights_application_type
  tags                = var.resource_tags
}

