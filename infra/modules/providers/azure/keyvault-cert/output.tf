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

output "cert_name" {
  value = var.key_vault_cert_name
}

output "public_cert" {
  value     = data.external.public_cert.result["cer"]
  sensitive = true
}

output "private_pfx" {
  value     = data.external.private_pfx.result["value"]
  sensitive = true
}

output "vault_id" {
  value = data.azurerm_key_vault.vault.id
}

