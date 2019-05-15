locals {
  service_plan_name          = "${var.name}-sp"
  app_insights_name          = "${var.name}-ai"
  resource_group_name        = "${var.name}-rg"
}

module "provider" {
  source = "../../modules/providers/azure/provider"
}

resource "azurerm_resource_group" "svcplan" {
  name     = "${local.resource_group_name}"
  location = "${var.resource_group_location}"
}

module "service_plan" {
  source                  = "../../modules/providers/azure/service-plan"
  resource_group_name     = "${azurerm_resource_group.svcplan.name}"
  service_plan_name       = "${local.service_plan_name}"
}

module "app_service" {
  source                           = "../../modules/providers/azure/app-service"
  app_service_name                 = "${var.app_service_name}"
  service_plan_name                = "${module.service_plan.service_plan_name}"
  service_plan_resource_group_name = "${azurerm_resource_group.svcplan.name}"
  app_insights_instrumentation_key = "${module.app_insight.app_insights_instrumentation_key}"
  docker_registry_server_url       = "${var.docker_registry_server_url}"
  docker_registry_server_username  = "${var.docker_registry_server_username}"
  docker_registry_server_password  = "${var.docker_registry_server_password}"
  vnet_name                        = "${module.vnet.vnet_name}"
  vnet_subnet_id                   = "${module.vnet.vnet_subnet_ids[0]}"
}

module "app_insight" {
  source                           = "../../modules/providers/azure/app-insights"
  service_plan_resource_group_name = "${azurerm_resource_group.svcplan.name}"
  appinsights_name                 = "${local.app_insights_name}"
}