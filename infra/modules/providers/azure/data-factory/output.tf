output "resource_group_name" {
  description = "The resource group name of the Service Bus namespace."
  value       = data.azurerm_resource_group.main.name
}

output "data_factory_name" {
  description = "The name of the Azure Data Factory created"
  value       = azurerm_data_factory.main.name
}

output "data_factory_id" {
  description = "The ID of the Azure Data Factory created"
  value       = azurerm_data_factory.main.id
}

output "identity_principal_id" {
  description = "The ID of the principal(client) in Azure active directory"
  value       = azurerm_data_factory.main.identity[0].principal_id
}

output "pipeline_name" {
  description = "the name of the pipeline created"
  value       = azurerm_data_factory_pipeline.main.name
}

output "trigger_interval" {
  description = "the trigger interval time for the pipeline created"
  value       = azurerm_data_factory_trigger_schedule.main.interval
}

output "sql_dataset_id" {
  description = "The ID of the SQL server dataset created"
  value       = azurerm_data_factory_dataset_sql_server_table.main.id
}

output "sql_linked_service_id" {
  description = "The ID of the SQL server Linked service created"
  value       = azurerm_data_factory_linked_service_sql_server.main.id
}

output "adf_identity_principal_id" {
  description = "The ID of the principal(client) in Azure active directory"
  value       = azurerm_data_factory.main.identity[0].principal_id
}

output "adf_identity_tenant_id" {
  description = "The Tenant ID for the Service Principal associated with the Managed Service Identity of this App Service."
  value       = azurerm_data_factory.main.identity[0].tenant_id
}

