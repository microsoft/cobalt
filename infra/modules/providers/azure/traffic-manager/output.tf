output "public_pip_id" {
  value = azurerm_public_ip.pip.id
}

output "tm_fqdn" {
  value = azurerm_traffic_manager_profile.profile.fqdn
}

output "public_pip_fqdn" {
  value = azurerm_public_ip.pip.fqdn
}

