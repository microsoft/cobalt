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

output "container_registry_id" {
  description = "The Container Registry ID."
  value       = azurerm_container_registry.container_registry.id
}

output "container_registry_login_server" {
  description = "The URL that can be used to log into the container registry."
  value       = azurerm_container_registry.container_registry.login_server
}

output "container_registry_name" {
  description = "The name of the azure container registry resource"
  value       = var.container_registry_name
}

output "admin_username" {
  description = "If admin access is enabled, this will be the username for the ACR"
  value       = azurerm_container_registry.container_registry.admin_username
  sensitive   = true
}

output "admin_password" {
  description = "If admin access is enabled, this will be the password for the ACR"
  value       = azurerm_container_registry.container_registry.admin_password
  sensitive   = true
}
