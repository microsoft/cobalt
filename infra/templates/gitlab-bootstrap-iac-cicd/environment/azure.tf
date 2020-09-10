locals {
  full_name = format("%s-%s", var.prefix, var.environment_name)
}

resource "azurerm_resource_group" "rg" {
  location = var.location
  name     = "rg-${local.full_name}"
  tags = {
    environment = var.environment_name
  }
}

resource "azuread_application" "app" {
  name = "sp-${local.full_name}"
}

resource "azuread_service_principal" "sp" {
  application_id = azuread_application.app.application_id
}

resource "random_password" "sp" {
  length  = 35
  upper   = true
  lower   = true
  special = false
}

resource "azuread_service_principal_password" "sp" {
  service_principal_id = azuread_service_principal.sp.id
  value                = random_password.sp.result
  end_date_relative    = "2400h"
}

resource "azurerm_role_assignment" "rg-owner" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Owner"
  principal_id         = azuread_service_principal.sp.id
}

resource "azurerm_storage_container" "tfstate" {
  name                  = format("tfstate-%s", var.environment_name)
  storage_account_name  = var.backend_storage_account_name
  container_access_type = "private"
}
