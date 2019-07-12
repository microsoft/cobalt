
module "provider" {
  source = "../../modules/providers/azure/provider"
}

provider "azurerm" {
  alias     = "csewhite"
  version   = "~>1.30.1"
  tenant_id = "89e14463-7a62-48bd-abe4-ef074c1c466b"
}

resource "azurerm_resource_group" "main" {
  name     = var.prefix
  location = var.resource_group_location
}

module "service_plan" {
  source              = "../../modules/providers/azure/service-plan"
  resource_group_name = azurerm_resource_group.main.name
  service_plan_name   = "${azurerm_resource_group.main.name}-sp"
}

module "app_service" {
  source                           = "../../modules/providers/azure/app-service"
  app_service_name                 = var.app_service_name
  service_plan_name                = module.service_plan.service_plan_name
  enable_auth                      = true
  app_service_auth                 = var.app_service_auth
  service_plan_resource_group_name = azurerm_resource_group.main.name
  docker_registry_server_url       = var.docker_registry_server_url
    providers = {
    "azurerm" = "azurerm.csewhite"
  }
}

