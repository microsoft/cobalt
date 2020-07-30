output "virtual_network_id" {
  description = "The id of the newly created vnet"
  value       = azurerm_virtual_network.vnet.id
}

output "subnet_ids" {
  description = "If supplied this represents the subnet IDs that should be allowed to access this resource"
  value       = azurerm_subnet.subnet[*].id
}