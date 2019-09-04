data "azurerm_container_registry" "acr" {
  name                = local.resolved_acr_name
  resource_group_name = local.resolved_acr_rg_name
  depends_on          = ["azurerm_resource_group.svcplan", "module.container_registry"]
}

# Build and push the app service image slot to enable continuous deployment scenarios. We're using ACR build tasks to remotely carry the docker build / push.
resource "null_resource" "acr_image_deploy" {
  count      = length(var.deployment_targets)
  depends_on = ["module.container_registry"]

  triggers = {
    images_to_deploy = "${join(",", [for target in var.deployment_targets : "${target.image_name}:${target.image_release_tag_prefix}"])}"
  }

  provisioner "local-exec" {
    command = "az acr build -t $IMAGE:$TAG -r $REGISTRY -f $DOCKERFILE $SOURCE"

    environment = {
      IMAGE      = var.deployment_targets[count.index].image_name
      TAG        = var.deployment_targets[count.index].image_release_tag_prefix
      REGISTRY   = module.container_registry.container_registry_name
      DOCKERFILE = var.acr_build_docker_file
      SOURCE     = var.acr_build_git_source_url
    }

  }
}

module "service_plan" {
  source              = "../../modules/providers/azure/service-plan"
  resource_group_name = azurerm_resource_group.svcplan.name
  service_plan_name   = local.sp_name
}

module "app_service" {
  source                           = "../../modules/providers/azure/app-service"
  service_plan_name                = module.service_plan.service_plan_name
  service_plan_resource_group_name = azurerm_resource_group.svcplan.name
  app_insights_instrumentation_key = module.app_insight.app_insights_instrumentation_key
  uses_acr                         = true
  azure_container_registry_name    = module.container_registry.container_registry_name
  docker_registry_server_url       = module.container_registry.container_registry_login_server
  docker_registry_server_username  = data.azurerm_container_registry.acr.admin_username
  docker_registry_server_password  = data.azurerm_container_registry.acr.admin_password
  uses_vnet                        = true
  vnet_name                        = module.vnet.vnet_name
  vnet_subnet_id                   = module.vnet.vnet_subnet_ids[0]
  vault_uri                        = module.keyvault.keyvault_uri
  app_service_config = {
    for target in var.deployment_targets :
    target.app_name => {
      image = "${target.image_name}:${target.image_release_tag_prefix}"
    }
  }
}

resource "azurerm_role_assignment" "acr_pull" {
  count                = length(var.deployment_targets)
  scope                = module.container_registry.container_registry_id
  role_definition_name = "AcrPull"
  principal_id         = module.app_service.app_service_identity_object_ids[count.index]
}

module "app_insight" {
  source                           = "../../modules/providers/azure/app-insights"
  service_plan_resource_group_name = azurerm_resource_group.svcplan.name
  appinsights_name                 = local.ai_name
  appinsights_application_type     = var.application_type
}

module "keyvault_appsvc_policy" {
  source         = "../../modules/providers/azure/keyvault-policy"
  instance_count = length(var.deployment_targets)
  vault_id       = module.keyvault_certificate.vault_id
  tenant_id      = module.app_service.app_service_identity_tenant_id
  object_ids     = module.app_service.app_service_identity_object_ids
}

module "app_monitoring" {
  source                            = "../../modules/providers/azure/app-monitoring"
  resource_group_name               = azurerm_resource_group.svcplan.name
  resource_ids                      = [module.service_plan.app_service_plan_id]
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
