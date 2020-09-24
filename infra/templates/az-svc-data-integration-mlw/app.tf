resource "azurerm_resource_group" "app_rg" {
  name     = local.app_rg_name
  location = local.region
}

# Note: this should be uncommented for production scenarios. It is commented
#       to support a teardown after deployment for the CICD pipeline.
# resource "azurerm_management_lock" "app_rg_lock" {
#   name       = local.app_rg_lock
#   scope      = azurerm_resource_group.app_rg.id
#   lock_level = "CanNotDelete"

#   lifecycle {
#     prevent_destroy = true
#   }
# }

module "network" {
  source              = "../../modules/providers/azure/network"
  vnet_name           = local.vnet_name
  resource_group_name = azurerm_resource_group.app_rg.name
  address_space       = var.address_space
  subnets             = local.subnets
}

module "container_registry" {
  source                           = "../../modules/providers/azure/container-registry"
  container_registry_name          = local.acr_name
  resource_group_name              = azurerm_resource_group.app_rg.name
  container_registry_admin_enabled = false
  // Note: only premium ACRs allow configuration of network access restrictions
  container_registry_sku = var.container_registry_sku
  subnet_id_whitelist    = module.network.subnet_ids
}

module "app_insights" {
  source                           = "../../modules/providers/azure/app-insights"
  service_plan_resource_group_name = azurerm_resource_group.app_rg.name
  appinsights_name                 = local.ai_name
  appinsights_application_type     = "web"
}


module "func_app_service_plan" {
  source              = "../../modules/providers/azure/service-plan"
  resource_group_name = azurerm_resource_group.app_rg.name
  service_plan_name   = local.func_app_sp_name
  # scaling_rules       = var.scaling_rules
  service_plan_tier     = var.func_app_service_plan_tier
  service_plan_size     = var.func_app_service_plan_size
  service_plan_kind     = var.func_app_service_plan_kind
  service_plan_reserved = var.func_app_service_plan_reserved
}




module "app_monitoring" {
  source                            = "../../modules/providers/azure/app-monitoring"
  resource_group_name               = azurerm_resource_group.app_rg.name
  resource_ids                      = [module.func_app_service_plan.app_service_plan_id]
  action_group_name                 = var.action_group_name
  action_group_email_receiver       = var.action_group_email_receiver
  metric_alert_name                 = var.metric_alert_name
  metric_alert_frequency            = var.metric_alert_frequency
  metric_alert_period               = var.metric_alert_period
  metric_alert_criteria_namespace   = var.metric_alert_criteria_namespace
  metric_alert_criteria_name        = var.metric_alert_criteria_name
  metric_alert_criteria_aggregation = var.metric_alert_criteria_aggregation
  metric_alert_criteria_operator    = var.metric_alert_criteria_operator
  metric_alert_criteria_threshold   = var.metric_alert_criteria_threshold
  monitoring_dimension_values       = var.monitoring_dimension_values
}

resource "azurerm_resource_group" "mlw_rg" {
  name     = local.mlw_rg_name
  location = local.region
}

module "mlw_app_insights" {
  source                           = "../../modules/providers/azure/app-insights"
  service_plan_resource_group_name = azurerm_resource_group.mlw_rg.name
  appinsights_name                 = local.mlw_ai_name
  appinsights_application_type     = "web"
}

module "ml_workspace" {
  source                  = "../../modules/providers/azure/ml-workspace"
  name                    = local.mlw_name
  resource_group_name     = azurerm_resource_group.mlw_rg.name
  application_insights_id = module.mlw_app_insights.id
  key_vault_id            = module.keyvault.keyvault_id
  storage_account_id      = module.sys_storage_account.id
  sku_name                = var.sku_name
}

module "function_app" {
  source                              = "../../modules/providers/azure/function-app"
  fn_name_prefix                      = local.func_app_name_prefix
  resource_group_name                 = azurerm_resource_group.app_rg.name
  service_plan_id                     = module.func_app_service_plan.app_service_plan_id
  storage_account_resource_group_name = module.sys_storage_account.resource_group_name
  storage_account_name                = module.sys_storage_account.name
  vnet_subnet_id                      = module.network.subnet_ids[0]
  fn_app_settings                     = local.func_app_settings
  fn_app_config                       = var.fn_app_config
}


module "data_factory" {
  source                           = "../../modules/providers/azure/data-factory"
  data_factory_name                = local.data_factory_name
  resource_group_name              = azurerm_resource_group.app_rg.name
  data_factory_runtime_name        = local.data_factory_runtime_name
  number_of_nodes                  = var.adf_number_of_nodes
  max_parallel_executions_per_node = var.adf_max_parallel_executions_per_node
  vnet_integration = {
    vnet_id     = module.network.subnet_ids[0]
    subnet_name = local.subnet_name
  }
  data_factory_pipeline_name     = local.data_factory_pipeline_name
  data_factory_trigger_name      = local.data_factory_trigger_name
  data_factory_trigger_interval  = var.adf_trigger_interval
  data_factory_trigger_frequency = var.adf_trigger_frequency
}

