resource "azurerm_resource_group" "main" {
  name     = local.app_rg_name
  location = local.region
}

module "service_plan" {
  source              = "../../modules/providers/azure/service-plan"
  resource_group_name = azurerm_resource_group.main.name
  service_plan_name   = local.sp_name
}

module "app_service" {
  source                           = "../../modules/providers/azure/app-service"
  service_plan_name                = module.service_plan.service_plan_name
  service_plan_resource_group_name = azurerm_resource_group.main.name
  docker_registry_server_url       = local.reg_url
  app_service_config               = local.app_services
}

