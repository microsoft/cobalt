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
  app_service_name                 = var.app_service_name
  service_plan_name                = module.service_plan.service_plan_name
  service_plan_resource_group_name = azurerm_resource_group.admin_rg.name
  app_insights_instrumentation_key = module.app_insights.app_insights_instrumentation_key
  providers = {
    "azurerm" = "azurerm.admin"
  }
}
