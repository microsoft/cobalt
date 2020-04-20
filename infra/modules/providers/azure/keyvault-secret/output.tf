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

output "keyvault_secret_attributes" {
  description = "The properties of a keyvault secret"
  /*Forced to use data block and resolve output of secrets into an array 
  as a workaround to an arm provider bug that will not allow updating app
  service settings with a keyvault version in a more direct way.*/
  value = [for i in range(length(azurerm_key_vault_secret.secret.*.id)) : data.azurerm_key_vault_secret.secrets[i]]
}
