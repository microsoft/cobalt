output "public_pip_id" {
  value = "${azurerm_public_ip.pip.id}"
}

output "fqdn" {
  value = "${azurerm_traffic_manager_profile.profile.fqdn}"
}
