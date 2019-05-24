locals {
  service_plan_name = "${local.prefix}-sp"
  app_insights_name = "${local.prefix}-ai"
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

module "keyvault_appsvc_policy" {
  source         = "../../modules/providers/azure/keyvault-policy"
  instance_count = "${length(keys(var.app_service_name))}"
  vault_id       = "${module.keyvault_certificate.vault_id}"
  tenant_id      = "${module.app_service.app_service_identity_tenant_id}"
  object_ids     = "${module.app_service.app_service_identity_object_ids}"
}

module "app_monitoring" {
  source                            = "../../modules/providers/azure/app-monitoring"
  resource_group_name               = "${azurerm_resource_group.svcplan.name}"
  resource_ids                      = ["${module.service_plan.app_service_plan_id}"]
  action_group_name                 = "${var.action_group_name}"
  action_group_email_receiver       = "${var.action_group_email_receiver}"
  metric_alert_criteria_namespace   = "${var.metric_alert_criteria_namespace}"
  metric_alert_name                 = "${var.metric_alert_name}"
  metric_alert_criteria_name        = "${var.metric_alert_criteria_name}"
  metric_alert_criteria_aggregation = "${var.metric_alert_criteria_aggregation}"
  metric_alert_criteria_operator    = "${var.metric_alert_criteria_operator}"
  metric_alert_criteria_threshold   = "${var.metric_alert_criteria_threshold}"
  scaling_values                    = "${var.scaling_values}"
}
