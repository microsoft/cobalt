module "provider" {
  source = "../../modules/providers/azure/provider"
}

data "azurerm_subscription" "current" {}

data "azurerm_client_config" "current" {}

locals {
  prefix        = "${lower(var.name)}-${lower(terraform.workspace)}"
  tenant_id     = data.azurerm_client_config.current.tenant_id
  admin_rg_name = "${local.prefix}-admin-rg"                                                                                             // name of resource group used for admin resources
  app_rg_name   = "${local.prefix}-app-rg"                                                                                               // name of app resource group
  sp_name       = "${local.prefix}-sp"                                                                                                   // name of service plan
  ai_name       = "${local.prefix}-ai"                                                                                                   // name of app insights
  kv_name       = format("%s%s-kv", format("%.10s", lower(var.name)), format("%.10s", lower(terraform.workspace)))                       // name of key vault
  acr_name      = replace(format("%s%sacr", format("%.10s", lower(var.name)), format("%.10s", lower(terraform.workspace))), "/\\W/", "") // name of acr
  app_names                      = keys(var.app_service_config)
  app_configs                    = values(var.app_service_config)
  app_service_name               = format("%s-%s", lower(${local.app_names}[count.index]), lower(terraform.workspace))
  ase_sub_id    = var.ase_subscription_id == "" ? data.azurerm_subscription.current.subscription_id : var.ase_subscription_id
  app_sub_id    = var.app_dev_subscription_id == "" ? data.azurerm_subscription.current.subscription_id : var.app_dev_subscription_id

  app_secrets = {
    "app-service-principal-object-id"      = module.app_service_principal_contributor.service_principal_object_id,
    "app-service-principal-application-id" = module.app_service_principal_contributor.service_principal_application_id,
    "app-service-principal-display-name"   = module.app_service_principal_contributor.service_principal_display_name,
    "app-service-principal-password"       = module.app_service_principal_contributor.service_principal_password,
    "container-registry-name"              = module.container_registry.container_registry_name
  }
  acr_secrets = {
    "acr-service-principal-object-id"      = module.acr_service_principal_acrpull.service_principal_object_id,
    "acr-service-principal-application-id" = module.acr_service_principal_acrpull.service_principal_application_id,
    "acr-service-principal-display-name"   = module.acr_service_principal_acrpull.service_principal_display_name
  }
  acr_password = {
    "acr-service-principal-password" = module.acr_service_principal_acrpull.service_principal_password
  }
  svc_principal_name     = "${local.prefix}-svc-principal"
  acr_svc_principal_name = "${local.prefix}-acr-svc-principal"
  // id of App Service Environment
  ase_id = "/subscriptions/${local.ase_sub_id}/resourceGroups/${var.ase_resource_group}/providers/Microsoft.Web/hostingEnvironments/${var.ase_name}"
}
