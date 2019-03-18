
output "container_registry_id" {
  description = "The id of the Container Registry"
  value       = "${azurerm_container_registry.container_registry.id}"
}

output "container_registry_login_server" {
  description = "The login server of the Container Registry"
  value       = "${azurerm_container_registry.container_registry.login_server}"
}

output "container_registry_admin_username" {
  description = "The Username  of the Container Registry"
  value       = "${azurerm_container_registry.container_registry.admin_username}"
}

output "container_registry_admin_password" {
  description = "The password of the Container Registry"
  value       = "${azurerm_container_registry.container_registry.admin_password}"
}