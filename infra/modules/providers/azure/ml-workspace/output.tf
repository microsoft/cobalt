output "id" {
  description = "The azure machine learning workspace ID."
  value       = azurerm_machine_learning_workspace.mlworkspace.id
}

output "mlw_identity_principal_id" {
  description = "The ID of the principal(client) in Azure active directory"
  value       = azurerm_machine_learning_workspace.mlworkspace.identity[0].principal_id
}