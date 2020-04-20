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

output "azure_functions_config_data" {
  description = "A map of the function apps created, keyed with the name, and the value has the created function app attributes"
  value = {
    for app in azurerm_function_app.main :
    app.name => {
      id   = app.id
      fqdn = app.default_hostname
    }
  }
}

output "uris" {
  description = "The URLs of the app services created"
  value       = azurerm_function_app.main.*.default_hostname
}

output "identity_tenant_id" {
  description = "The Tenant ID for the Service Principal associated with the Managed Service Identity of this Function App."
  value       = azurerm_function_app.main[0].identity[0].tenant_id
}

output "identity_object_ids" {
  description = "The Principal IDs for the Service Principal associated with the Managed Service Identity for all Function Apps."
  value       = azurerm_function_app.main.*.identity.0.principal_id
}
