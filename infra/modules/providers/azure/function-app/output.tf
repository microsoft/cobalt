// This configures Terraform to display the module's output during the `terraform plan` and `terraform apply` steps.
output "function_app_ids" {
  description = "The resource ids of the function app created."
  value       = azurerm_function_app.main.*.id
}

output "azure_function_url" {
  description = "The URLs of the app services created."
  value       = azurerm_function_app.main.*.default_hostname
}

output "app_service_type" {
  description = "The type of app service created."
  value       = azurerm_function_app.main.*.kind
}

output "azure_functionapp_name" {
  description = "The name of the function app"
  value       = azurerm_function_app.main.*.name
}

output "function_app_identity_object_ids" {
  description = "The Principal IDs for the Service Principal associated with the Managed Service Identity for all App Services."
  value       = azurerm_function_app.main.*.identity.0.principal_id
}

output "function_app_identity_tenant_id" {
  description = "The Tenant ID for the Service Principal associated with the Managed Service Identity of this App Service."
  value       = azurerm_function_app.main[0].identity[0].tenant_id
}