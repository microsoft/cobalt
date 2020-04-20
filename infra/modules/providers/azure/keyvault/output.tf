//  Copyright © Microsoft Corporation
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

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

