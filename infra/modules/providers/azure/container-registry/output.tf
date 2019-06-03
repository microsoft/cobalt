output "container_registry_id" {
  description = "The Container Registry ID."
  value       = "${azurerm_container_registry.container_registry.id}"
}

output "container_registry_login_server" {
  description = "The URL that can be used to log into the container registry."  
  value       = "${azurerm_container_registry.container_registry.login_server}"
}

output "container_registry_admin_username" {
  description = "The Username associated with the Container Registry Admin account - if the admin account is enabled."
  value       = "${azurerm_container_registry.container_registry.admin_username}"
  sensitive   = true
}
