resource "random_string" "rand" {
  length  = 4
  special = false
  number  = false
  upper   = false
}

resource "azurerm_resource_group" "ci" {
  name     = format("rg-%s-ci", var.prefix)
  location = var.location
}

resource "azurerm_storage_account" "ci" {
  name                = format("backendstate%s", random_string.rand.result)
  resource_group_name = azurerm_resource_group.ci.name
  location            = azurerm_resource_group.ci.location

  min_tls_version          = "TLS1_2"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate-terraform-bootstrap"
  storage_account_name  = azurerm_storage_account.ci.name
  container_access_type = "private"
}

data "azurerm_client_config" "current" {}

module "dev" {
  source                       = "./environment"
  acr_id                       = azurerm_container_registry.acr.id
  environment_name             = "dev"
  location                     = var.location
  subscription_id              = data.azurerm_client_config.current.subscription_id
  backend_storage_account_name = azurerm_storage_account.ci.name
  prefix                       = var.prefix
}

module "integration" {
  source                        = "./environment"
  acr_id                        = azurerm_container_registry.acr.id
  environment_name              = "integration"
  location                      = var.location
  subscription_id               = data.azurerm_client_config.current.subscription_id
  backend_storage_account_name  = azurerm_storage_account.ci.name
  prefix                        = var.prefix
}

module "prod" {
  source                        = "./environment"
  acr_id                        = azurerm_container_registry.acr.id
  environment_name              = "prod"
  location                      = var.location
  subscription_id               = data.azurerm_client_config.current.subscription_id
  backend_storage_account_name  = azurerm_storage_account.ci.name
  prefix                        = var.prefix
}
