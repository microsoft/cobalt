# The dependency of these values on the keyvault access policy is required in
# order to create an explicit dependency between the access policy that
# allows the service principal executing the deployment and the keyvault
# ID. This ensures that the access policy is always configured prior to
# managing entitites within the keyvault.
#
# More documentation on this stanza can be found here:
#   https://www.terraform.io/docs/configuration/outputs.html#depends_on-explicit-output-dependencies

output "keyvault_id" {
  description = "The id of the Keyvault"
  value       = azurerm_key_vault.keyvault.id
  depends_on = [
    module.deployment_service_principal_keyvault_access_policies
  ]
}

output "keyvault_uri" {
  description = "The uri of the keyvault"
  value       = azurerm_key_vault.keyvault.vault_uri
  depends_on = [
    module.deployment_service_principal_keyvault_access_policies
  ]
}

output "keyvault_name" {
  description = "The name of the Keyvault"
  value       = azurerm_key_vault.keyvault.name
  depends_on = [
    module.deployment_service_principal_keyvault_access_policies
  ]
}

