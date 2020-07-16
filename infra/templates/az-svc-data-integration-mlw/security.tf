###
# This next block of Terraform configures the Service Principal
# that will be used by the application teams to deploy service
# code, configure and manage KeyVault secrets and manage App
# Service plans, among other things.
###

locals {
  rbac_contributor_scopes = concat(
    # App services and the associated slots -- enables management of deployments, etc...
    # Note: RBAC for slots is inherited and does not need to be configured separately
    # module.app_service.app_service_ids,

    # The ML workspace Id
    [module.ml_workspace.id],

    #The Function App Id
    module.function_app.function_app_ids,
  )

  contributor_role_name         = "Contributor"
  storage_contributor_role_name = "Storage Blob Data Contributor"

}

module "ad_application" {
  source               = "../../modules/providers/azure/ad-application"
  resource_access_type = "Scope"
  ad_app_config = [
    {
      app_name   = local.ad_app_name
      reply_urls = []
    }
  ]
  resource_app_id  = local.graph_id
  resource_role_id = local.graph_role_id
}

module "app_management_service_principal" {
  source          = "../../modules/providers/azure/service-principal"
  create_for_rbac = true
  display_name    = local.ad_app_management_name
  role_name       = "Contributor"
  role_scopes     = local.rbac_contributor_scopes
}

# resource "azurerm_role_assignment" "aks_acr_pull" {
#   role_definition_name = "AcrPull"
#   principal_id         = module.app_management_service_principal.service_principal_object_id
#   scope                = module.container_registry.container_registry_id
# }

# Create a Role Assignment with Storage Blob Data Contributor role for Data Factory to access storage account
resource "azurerm_role_assignment" "adf_app_storage_role_ra" {
  role_definition_name = local.storage_contributor_role_name
  principal_id         = module.data-factory.adf_identity_principal_id
  scope                = module.app_storage_account.id
}

# Create a Role Assignment with Storage Blob Data Contributor role for Machine Learning to access storage account
resource "azurerm_role_assignment" "mlw_sys_storage_ra" {
  role_definition_name = local.storage_contributor_role_name
  principal_id         = module.ml_workspace.mlw_identity_principal_id
  scope                = module.ml_workspace.id
}

# Create a Role Assignment with Storage Blob Data Contributor role for Machine Learning to access storage account
resource "azurerm_role_assignment" "mlw_app_storage_ra" {
  role_definition_name = local.storage_contributor_role_name
  principal_id         = module.ml_workspace.mlw_identity_principal_id
  scope                = module.app_storage_account.id
}

# Create a Role Assignment with Contributor role for Machine Learning to access Container Registry
resource "azurerm_role_assignment" "mlw_acr_ra" {
  scope                = module.container_registry.container_registry_id
  role_definition_name = local.contributor_role_name
  principal_id         = module.ml_workspace.mlw_identity_principal_id
}

# Create a Role Assignment with Contributor role for Machine Learning to access Keyvault
resource "azurerm_role_assignment" "mlw_kv_ra" {
  scope                = module.keyvault.keyvault_id
  role_definition_name = local.contributor_role_name
  principal_id         = module.ml_workspace.mlw_identity_principal_id
}

# Create a Role Assignment with Contributor role for Machine Learning to access Application Insights
resource "azurerm_role_assignment" "mlw_ai_ra" {
  scope                = module.app_insights.id
  role_definition_name = local.contributor_role_name
  principal_id         = module.ml_workspace.mlw_identity_principal_id
}