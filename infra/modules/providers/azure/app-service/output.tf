output "resource_group_name" {
  description = "The name of the resource group created"
  value = "${azurerm_resource_group.appsvc.name}"
}

output "app_service_uri" {
  description = "The URL of the app service created"
  value       = "${azurerm_app_service.appsvc.default_site_hostname}"
}
