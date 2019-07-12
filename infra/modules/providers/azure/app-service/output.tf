output "app_service_uri" {
  description = "The URL of the app service created"
  value       = azurerm_app_service.appsvc.*.default_site_hostname
}

output "app_service_ids" {
  description = "The resource ids of the app service created"
  value       = azurerm_app_service.appsvc.*.id
}

output "app_service_names" {
  description = "The names of the app service created"
  value = [
    for name in keys(var.app_service_name):
    "${lower(name)}-${lower(terraform.workspace)}"
  ]
}

output "app_service_identity_tenant_id" {
  description = "The Tenant ID for the Service Principal associated with the Managed Service Identity of this App Service."
  value       = azurerm_app_service.appsvc[0].identity[0].tenant_id
}

output "app_service_identity_object_ids" {
  description = "The Principal IDs for the Service Principal associated with the Managed Service Identity for all App Services."
  value       = azurerm_app_service.appsvc.*.identity.0.principal_id
}

