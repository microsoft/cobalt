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

output "service_principal_object_id" {
  description = "The ID of the Azure AD Service Principal"
  value       = azuread_service_principal.sp[0].object_id
}

output "service_principal_application_id" {
  description = "The ID of the Azure AD Application"
  value       = azuread_service_principal.sp[0].application_id
}

output "service_principal_display_name" {
  description = "The Display Name of the Azure AD Application associated with this Service Principal"
  value       = azuread_service_principal.sp[0].display_name
}

output "service_principal_password" {
  description = "The password of the generated service principal. This is only exported when create_for_rbac is true."
  value       = azuread_service_principal_password.sp[0].value
  sensitive   = true
}
