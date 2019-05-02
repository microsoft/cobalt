output "app_service_uri" {
  description = "The URL of the app service created"
  value       = ["${azurerm_app_service.appsvc.*.default_site_hostname}"]
}
