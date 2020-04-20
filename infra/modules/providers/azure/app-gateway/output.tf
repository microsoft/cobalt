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

output "appgateway_name" {
  description = "The name of the Application Gateway created"
  value       = azurerm_application_gateway.appgateway.name
}

output "appgateway_ipconfig" {
  description = "The Application Gateway IP Configuration"
  value       = azurerm_application_gateway.appgateway.gateway_ip_configuration
}

output "appgateway_frontend_ip_configuration" {
  description = "The Application Gateway Frontend IP Configuration"
  value       = azurerm_application_gateway.appgateway.frontend_ip_configuration
}

output "appgateway_health_probe_backend_status" {
  value = data.external.app_gw_health.result["health"]
}

output "app_gateway_health_probe_backend_address" {
  value = data.external.app_gw_health.result["address"]
}

