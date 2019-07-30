// This file contains all of the resources that exist within the admin subscription. Design documentation
// with more information on exactly what resources live here can be found at ./docs/design.md

// Note: unfortunately the alias cannot be configured by passing a variable through
// the module initialization!
provider "azurerm" {
  alias           = "admin"
  subscription_id = var.ase_subscription_id
}


resource "azurerm_resource_group" "admin_rg" {
  name     = local.admin_rg_name
  location = var.resource_group_location
  provider = azurerm.admin
}

resource "azurerm_management_lock" "admin_rg_lock" {
  name       = format("%s-delete-lock", local.admin_rg_name)
  scope      = azurerm_resource_group.admin_rg.id
  lock_level = "CanNotDelete"
  provider   = azurerm.admin

  lifecycle {
    prevent_destroy = true
  }
}

module "app_insights" {
  source                           = "../../modules/providers/azure/app-insights"
  service_plan_resource_group_name = azurerm_resource_group.admin_rg.name
  appinsights_name                 = local.ai_name
  appinsights_application_type     = "Web"
  providers = {
    "azurerm" = "azurerm.admin"
  }
}


module "service_plan" {
  source                     = "../../modules/providers/azure/service-plan"
  resource_group_name        = azurerm_resource_group.admin_rg.name
  service_plan_name          = local.sp_name
  scaling_rules              = var.scaling_rules
  service_plan_tier          = "Isolated"
  service_plan_size          = var.service_plan_size
  service_plan_kind          = var.service_plan_kind
  app_service_environment_id = local.ase_id
  providers = {
    "azurerm" = "azurerm.admin"
  }
}

module "app_service" {
  source                           = "../../modules/providers/azure/app-service"
  service_plan_name                = module.service_plan.service_plan_name
  service_plan_resource_group_name = azurerm_resource_group.admin_rg.name
  app_insights_instrumentation_key = module.app_insights.app_insights_instrumentation_key
  azure_container_registry_name    = module.container_registry.container_registry_name
  docker_registry_server_url       = module.container_registry.container_registry_login_server
  docker_registry_server_username  = module.container_registry.admin_username
  docker_registry_server_password  = module.container_registry.admin_password
  external_tenant_id               = var.external_tenant_id
  app_service_config = {
    for target in var.deployment_targets :
    target.app_name => {
      image        = "${target.image_name}:${target.image_release_tag_prefix}-${lower(terraform.workspace)}"
      ad_client_id = target.auth_client_id
    }
  }
  providers = {
    "azurerm" = "azurerm.admin"
  }
}
