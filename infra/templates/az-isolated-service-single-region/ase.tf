// This file contains all of the resources that exist within the admin subscription. Design documentation
// with more information on exactly what resources live here can be found at ./docs/design.md

// Note: unfortunately the alias cannot be configured by passing a variable through
// the module initialization!
provider "azurerm" {
  alias           = "admin"
  subscription_id = local.ase_sub_id
}

resource "azurerm_resource_group" "admin_rg" {
  name     = local.admin_rg_name
  location = local.region
  provider = azurerm.admin
}

# Note: this should be uncommented for production scenarios. It is commented
#       to support a teardown after deployment for the Cobalt CICD pipeline.
# resource "azurerm_management_lock" "admin_rg_lock" {
#   name       = local.admin_rg_lock
#   scope      = azurerm_resource_group.admin_rg.id
#   lock_level = "CanNotDelete"
#   provider   = azurerm.admin

#   lifecycle {
#     prevent_destroy = true
#   }
# }

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
  app_service_name_prefix          = local.app_svc_name_prefix
  service_plan_resource_group_name = azurerm_resource_group.admin_rg.name
  app_insights_instrumentation_key = module.app_insights.app_insights_instrumentation_key
  uses_acr                         = true
  app_service_settings             = var.app_service_settings
  vault_uri                        = module.keyvault.keyvault_uri
  azure_container_registry_name    = module.container_registry.container_registry_name
  docker_registry_server_url       = module.container_registry.container_registry_login_server
  docker_registry_server_username  = module.acr_service_principal_acrpull.service_principal_application_id
  docker_registry_server_password  = format("@Microsoft.KeyVault(SecretUri=%s)", azurerm_key_vault_secret.acr_sp_pwd_secret.id)
  app_service_config = {
    for target in var.unauthn_deployment_targets :
    target.app_name => {
      image            = ""
      linux_fx_version = "DOCKER"
      app_settings     = {}
      app_command_line = null
    }
  }
  providers = {
    "azurerm" = "azurerm.admin"
  }
}

module "app_service_keyvault_access_policy" {
  source                  = "../../modules/providers/azure/keyvault-policy"
  vault_id                = module.keyvault.keyvault_id
  tenant_id               = module.app_service.app_service_identity_tenant_id
  object_ids              = module.app_service.app_service_identity_object_ids
  key_permissions         = ["get", "list"]
  secret_permissions      = ["get", "list"]
  certificate_permissions = ["get", "list"]
}

module "authn_app_service" {
  source                           = "../../modules/providers/azure/app-service"
  service_plan_name                = module.service_plan.service_plan_name
  app_service_name_prefix          = local.auth_svc_name_prefix
  service_plan_resource_group_name = azurerm_resource_group.admin_rg.name
  app_insights_instrumentation_key = module.app_insights.app_insights_instrumentation_key
  uses_acr                         = true
  vault_uri                        = module.keyvault.keyvault_uri
  azure_container_registry_name    = module.container_registry.container_registry_name
  docker_registry_server_url       = module.container_registry.container_registry_login_server
  docker_registry_server_username  = module.acr_service_principal_acrpull.service_principal_application_id
  docker_registry_server_password  = format("@Microsoft.KeyVault(SecretUri=%s)", azurerm_key_vault_secret.acr_sp_pwd_secret.id)
  app_service_config = {
    for target in var.authn_deployment_targets :
    target.app_name => {
      image            = ""
      linux_fx_version = "DOCKER"
      app_settings     = {}
      app_command_line = null
    }
  }
  providers = {
    "azurerm" = "azurerm.admin"
  }
}

module "authn_app_service_keyvault_access_policy" {
  source                  = "../../modules/providers/azure/keyvault-policy"
  vault_id                = module.keyvault.keyvault_id
  tenant_id               = module.authn_app_service.app_service_identity_tenant_id
  object_ids              = module.authn_app_service.app_service_identity_object_ids
  key_permissions         = ["get", "list"]
  secret_permissions      = ["get", "list"]
  certificate_permissions = ["get", "list"]
}

module "ad_application" {
  source = "../../modules/providers/azure/ad-application"
  ad_app_config = [
    for config in module.authn_app_service.app_service_config_data :
    {
      app_name   = format("%s-%s", config.app_name, var.auth_suffix)
      reply_urls = [format("https://%s", config.app_fqdn), format("https://%s/.auth/login/aad/callback", config.app_fqdn), format("https://%s", config.slot_fqdn), format("https://%s/.auth/login/aad/callback", config.slot_fqdn)]
    }
  ]
  resource_app_id  = var.graph_id
  resource_role_id = var.graph_role_id
}

resource "null_resource" "auth" {
  count      = length(module.authn_app_service.app_service_uris)
  depends_on = [module.ad_application.azuread_config_data]

  /* Orchestrates the destroy and create process of null_resource.auth dependencies
  /  during subsequent deployments that require new resources.
  */
  lifecycle {
    create_before_destroy = true
  }

  triggers = {
    app_service = join(",", module.authn_app_service.app_service_uris)
  }

  provisioner "local-exec" {
    command = <<EOF
      az webapp auth update                     \
        --subscription "$SUBSCRIPTION_ID"       \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --name "$APPNAME"                       \
        --enabled true                          \
        --action LoginWithAzureActiveDirectory  \
        --aad-token-issuer-url "$ISSUER"        \
        --aad-client-id "$APPID"                \
      && az webapp auth update                  \
        --subscription "$SUBSCRIPTION_ID"       \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --name "$APPNAME"                       \
        --slot "$SLOTSHORTNAME"                 \
        --enabled true                          \
        --action LoginWithAzureActiveDirectory  \
        --aad-token-issuer-url "$ISSUER"        \
        --aad-client-id "$APPID"
      EOF

    environment = {
      SUBSCRIPTION_ID     = data.azurerm_client_config.current.subscription_id
      RESOURCE_GROUP_NAME = azurerm_resource_group.admin_rg.name
      SLOTSHORTNAME       = module.authn_app_service.app_service_config_data[count.index].slot_short_name
      APPNAME             = module.authn_app_service.app_service_config_data[count.index].app_name
      ISSUER              = format("https://sts.windows.net/%s", local.tenant_id)
      APPID               = module.ad_application.azuread_config_data[format("%s-%s", module.authn_app_service.app_service_config_data[count.index].app_name, var.auth_suffix)].application_id
    }
  }
}
