# output "fqdns" {
#   value = [
#     for uri in concat(module.app_service.app_service_uris) :
#     "http://${uri}"
#   ]
# }

# output "webapp_names" {
#   value = concat(module.app_service.app_service_names)
# }

output "app_insights_id" {
  value = module.app_insights.app_insights_app_id
}

output "service_plan_name" {
  value = module.func_app_service_plan.service_plan_name
}

output "service_plan_id" {
  value = module.func_app_service_plan.app_service_plan_id
}

output "app_dev_resource_group" {
  value = azurerm_resource_group.app_rg.name
}

output "keyvault_name" {
  value = module.keyvault.keyvault_name
}

output "keyvault_uri" {
  value = module.keyvault.keyvault_uri
}

output "keyvault_secret_attributes" {
  description = "The properties of all provisioned keyvault secrets"
  value = {
    for secret in module.keyvault_secrets.keyvault_secret_attributes :
    secret.name => {
      id      = secret.id
      value   = secret.value
      version = secret.version
    }
  }
  sensitive = true
}

output "acr_name" {
  value = module.container_registry.container_registry_name
}

output "sys_storage_account" {
  description = "The name of the ml storage account."
  value       = module.sys_storage_account.name
}

output "sys_storage_account_id" {
  description = "The resource identifier of the ml storage account."
  value       = module.sys_storage_account.id
}

output "sys_storage_account_containers" {
  description = "Map of ml storage account containers."
  value       = module.sys_storage_account.containers
}

output "app_storage_account_name" {
  description = "The name of the dataprep storage account."
  value       = module.app_storage_account.name
}

output "app_storage_account_id" {
  description = "The resource identifier of the dataprep storage account."
  value       = module.app_storage_account.id
}

output "app_storage_account_containers" {
  description = "Map of dataprep storage account containers."
  value       = module.app_storage_account.containers
}

output "mlw_id" {
  description = "The azure machine learning workspace ID."
  value       = module.ml_workspace.id
}

output "mlw_dev_resource_group" {
  value = azurerm_resource_group.mlw_rg.name
}

output "data_factory_name" {
  value = module.data-factory.data_factory_name
}

output "azure_functionapp_name" {
  value = module.function_app.azure_functionapp_name
}

# This output is required for proper integration testing.
output "cosmosdb_resource_group_name" {
  value = module.cosmosdb.resource_group_name
}

# This output is required for proper integration testing.
output "cosmosdb_account_name" {
  value = module.cosmosdb.account_name
}

output "properties" {
  description = "Properties of the deployed CosmosDB account."
  value       = module.cosmosdb.properties
  sensitive   = true
}