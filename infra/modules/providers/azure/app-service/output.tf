output "appsvc_name" {
  description = "The name of the app service created"
  value       = "${azurerm_app_service.appsvc.name}"
}

output "appsvc_uri" {
  description = "The URL of the app service created"
  value       = "${azurerm_app_service.appsvc.default_site_hostname}"
}
