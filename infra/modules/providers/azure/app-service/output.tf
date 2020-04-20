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

output "app_service_uris" {
  description = "The URLs of the app services created"
  value       = azurerm_app_service.appsvc.*.default_site_hostname
}

output "app_service_ids" {
  description = "The resource ids of the app services created"
  value       = azurerm_app_service.appsvc.*.id
}

output "app_service_names" {
  description = "The names of the app services created"
  value = [
    for name in keys(var.app_service_config) :
    "${var.app_service_name_prefix}-${lower(name)}"
  ]
}

output "app_service_config_data" {
  description = "A list of app services paired with their fqdn and slot settings."
  value = [
    for i in range(length(data.azurerm_app_service.all)) :
    {
      slot_short_name = azurerm_app_service_slot.appsvc_staging_slot.*.name[i]
      slot_fqdn       = azurerm_app_service_slot.appsvc_staging_slot.*.default_site_hostname[i]
      app_name        = azurerm_app_service_slot.appsvc_staging_slot.*.app_service_name[i]
      app_fqdn        = azurerm_app_service.appsvc.*.default_site_hostname[i]
    }
  ]
}

output "app_service_identity_tenant_id" {
  description = "The Tenant ID for the Service Principal associated with the Managed Service Identity of this App Service."
  value       = azurerm_app_service.appsvc[0].identity[0].tenant_id
}

output "app_service_identity_config_data" {
  description = "The Principal IDs for the Service Principal associated with the Managed Service Identity for all App Services."
  value = {
    for app in azurerm_app_service.appsvc :
    app.name => app.identity.0.principal_id
  }
}

output "app_service_identity_object_ids" {
  description = "The Principal IDs for the Service Principal associated with the Managed Service Identity for all App Services."
  value       = azurerm_app_service.appsvc.*.identity.0.principal_id
}