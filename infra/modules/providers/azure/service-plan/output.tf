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

output "service_plan_name" {
  description = "The name of the service plan created"
  value       = azurerm_app_service_plan.svcplan.name
}

output "service_plan_kind" {
  description = "The kind of service plan created"
  value       = azurerm_app_service_plan.svcplan.kind
}

output "app_service_plan_id" {
  value = azurerm_app_service_plan.svcplan.id
}

