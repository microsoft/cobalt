provider "azuread" {
  version = 0.8
}
provider "random" {
  version = 2.2
}
provider "azurerm" {
  version = "=2.0.0"
  features {}
}

data "azurerm_subscription" "sub" {
}

data "azurerm_client_config" "example" {
}

resource "azuread_application" "app" {
  name = "bootstrap-deploy-app"
}

resource "azuread_service_principal" "sp" {
  application_id = azuread_application.app.application_id
}

resource "azurerm_role_assignment" "rbac" {
  scope                = data.azurerm_subscription.sub.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.sp.object_id
}

resource "random_string" "random" {
  length  = 16
  special = true
}

resource "azuread_service_principal_password" "passwd" {
  service_principal_id = azuread_service_principal.sp.id
  value                = random_string.random.result
  end_date             = "2099-01-01T01:02:03Z"
}

resource "azurerm_resource_group" "rg" {
  name     = "bootstrap-iac-tf-workspaces"
  location = "Central US"
  tags = {
    bootstrap = "bootstrap"
  }
}

locals {
  tf_state_container_name = "bootstraptfstate"
}

resource "azurerm_storage_account" "acct" {
  count                    = length(var.environments)
  name                     = format("iactf%s", var.environments[count.index].environment)
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = var.environments[count.index].environment
    bootstrap   = "bootstrap"
  }
}

resource "azurerm_storage_container" "container" {
  count                 = length(var.environments)
  name                  = local.tf_state_container_name
  storage_account_name  = azurerm_storage_account.acct[count.index].name
  container_access_type = "private"
}
