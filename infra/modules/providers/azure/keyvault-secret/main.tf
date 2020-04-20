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

locals {
  secret_names = keys(var.secrets)
}

resource "azurerm_key_vault_secret" "secret" {
  count        = length(var.secrets)
  name         = local.secret_names[count.index]
  value        = var.secrets[local.secret_names[count.index]]
  key_vault_id = var.keyvault_id
}

data "azurerm_key_vault_secret" "secrets" {
  count        = length(var.secrets)
  depends_on   = [azurerm_key_vault_secret.secret]
  name         = local.secret_names[count.index]
  key_vault_id = var.keyvault_id
}
