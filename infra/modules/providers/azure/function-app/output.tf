output "azure_functions_config_data" {
  description = "A map of the function apps created, keyed with the name, and the value has the created function app attributes"
  value = {
    for app in azurerm_function_app.main :
    app.name => {
      id   = app.id
      fqdn = app.default_hostname
    }
  }
}

output "uris" {
  description = "The URLs of the app services created"
  value       = azurerm_function_app.main.*.default_hostname
}

output "identity_tenant_id" {
  description = "The Tenant ID for the Service Principal associated with the Managed Service Identity of this Function App."
  value       = azurerm_function_app.main[0].identity[0].tenant_id
}

output "identity_object_ids" {
  description = "The Principal IDs for the Service Principal associated with the Managed Service Identity for all Function Apps."
  value       = azurerm_function_app.main.*.identity.0.principal_id
}
