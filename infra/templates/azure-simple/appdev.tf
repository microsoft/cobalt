locals {
  service_plan_name   = "${var.name}-sp"
  app_insights_name   = "${var.name}-ai"
}

module "provider" {
  source = "../../modules/providers/azure/provider"
}

module "service_plan" {
  source              = "../../modules/providers/azure/service-plan"
  resource_group_name = "${azurerm_resource_group.svcplan.name}"
  service_plan_name   = "${local.service_plan_name}"
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
  vault_uri                        = "${module.keyvault.keyvault_uri}"
}

module "app_insight" {
  source                           = "../../modules/providers/azure/app-insights"
  service_plan_resource_group_name = "${azurerm_resource_group.svcplan.name}"
  appinsights_name                 = "${local.app_insights_name}"
}

module "keyvault-appsvc-policy" {
  source              = "../../modules/providers/azure/keyvault-policy"
  instance_count      = "${length(keys(var.app_service_name))}"
  vault_id            = "${module.keyvault.keyvault_id}"
  tenant_id           = "${module.app_service.app_service_identity_tenant_id}"
  object_ids          = ["${module.app_service.app_service_identity_object_ids}"]
}
