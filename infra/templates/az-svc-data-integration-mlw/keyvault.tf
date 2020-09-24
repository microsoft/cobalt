locals {
  secrets_map = {
    # App Insights Secrets
    appinsights-key     = module.app_insights.app_insights_instrumentation_key
    mlw-appinsights-key = module.mlw_app_insights.app_insights_instrumentation_key
    # Storage Account Secrets
    sys-storage-account-key = module.sys_storage_account.primary_access_key
    app-storage-account-key = module.app_storage_account.primary_access_key
    app-sp-tenant-id        = data.azurerm_client_config.current.tenant_id
    # AAD Application Secrets
    aad-client-id = module.ad_application.azuread_app_ids[0]
    # Service Principal Secrets
    app-sp-username = module.app_management_service_principal.service_principal_application_id
    app-sp-password = module.app_management_service_principal.service_principal_password
    # Cosmos Cluster Secrets 
    cosmos-endpoint    = module.cosmosdb.properties.cosmosdb.endpoint
    cosmos-primary-key = module.cosmosdb.properties.cosmosdb.primary_master_key
    cosmos-connection  = module.cosmosdb.properties.cosmosdb.connection_strings[0]
    #Azure function App
    function-app-key = "This will be updated in Azure DevOps pipline"
  }

  output_secret_map = {
    for secret in module.keyvault_secrets.keyvault_secret_attributes :
    secret.name => secret.id
  }
  app_setting_kv_format = "@Microsoft.KeyVault(SecretUri=%s)"
}

module "keyvault" {
  source              = "../../modules/providers/azure/keyvault"
  keyvault_name       = local.kv_name
  resource_group_name = azurerm_resource_group.app_rg.name
  subnet_id_whitelist = module.network.subnet_ids
}

module "keyvault_secrets" {
  source      = "../../modules/providers/azure/keyvault-secret"
  keyvault_id = module.keyvault.keyvault_id
  secrets     = local.secrets_map
}


module "function_app_keyvault_access_policy" {
  source                  = "../../modules/providers/azure/keyvault-policy"
  vault_id                = module.keyvault.keyvault_id
  tenant_id               = module.function_app.function_app_identity_tenant_id
  object_ids              = module.function_app.function_app_identity_object_ids
  key_permissions         = ["get", "list"]
  secret_permissions      = ["get", "list"]
  certificate_permissions = ["get", "list"]
}

module "adf_keyvault_access_policy" {
  source                  = "../../modules/providers/azure/keyvault-policy"
  vault_id                = module.keyvault.keyvault_id
  tenant_id               = module.data-factory.adf_identity_tenant_id
  object_ids              = [module.data-factory.adf_identity_principal_id]
  key_permissions         = ["get", "list"]
  secret_permissions      = ["get", "list"]
  certificate_permissions = ["get", "list"]
}