resource "azurerm_container_registry" "acr" {
  name                = format("acr%s", random_string.rand.result)
  resource_group_name = azurerm_resource_group.ci.name
  location            = azurerm_resource_group.ci.location
  sku                 = "Basic"
}

resource "azuread_application" "acr" {
  name = format("acr-push-%s", random_string.rand.result)
}

resource "azuread_service_principal" "acr" {
  application_id = azuread_application.acr.application_id
}

resource "random_password" "acr" {
  length  = 35
  upper   = true
  lower   = true
  special = false
}

resource "azuread_service_principal_password" "acr" {
  service_principal_id = azuread_service_principal.acr.id
  value                = random_password.acr.result
  end_date_relative    = "2400h"
}

resource "azurerm_role_assignment" "acr_push" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPush"
  principal_id         = azuread_service_principal.acr.id
}

resource "azurerm_role_assignment" "acr_pull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azuread_service_principal.acr.id
}
