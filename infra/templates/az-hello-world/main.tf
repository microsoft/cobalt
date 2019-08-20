
module "provider" {
  source = "../../modules/providers/azure/provider"
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
  service_plan_name                = module.service_plan.service_plan_name
  service_plan_resource_group_name = azurerm_resource_group.main.name
  docker_registry_server_url       = var.docker_registry_server_url
  app_service_config = {
    for target in var.deployment_targets :
    target.app_name => {
      image = "${target.image_name}:${target.image_release_tag_prefix}"
    }
  }
}

