output "container_registry_id" {
  description = "The Container Registry ID."
  value       = azurerm_container_registry.container_registry.id
}

output "container_registry_login_server" {
  description = "The URL that can be used to log into the container registry."
  value       = azurerm_container_registry.container_registry.login_server
}

output "container_registry_name" {
  description = "The name of the azure container registry resource"
  value       = var.container_registry_name
}

output "admin_username" {
  description = "If admin access is enabled, this will be the username for the ACR"
  value       = azurerm_container_registry.container_registry.admin_username
  sensitive   = true
}

output "admin_password" {
  description = "If admin access is enabled, this will be the password for the ACR"
  value       = azurerm_container_registry.container_registry.admin_password
  sensitive   = true
}
