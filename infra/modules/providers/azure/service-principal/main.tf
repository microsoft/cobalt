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

resource "random_string" "password" {
  length = 16
}

locals {
  sps_to_create = var.create_for_rbac == true ? 1 : 0
  sp_password   = sha256(bcrypt(random_string.password.result))
}

resource "azuread_application" "sp" {
  count = local.sps_to_create
  name  = var.display_name
}

resource "azuread_service_principal" "sp" {
  count          = local.sps_to_create
  application_id = azuread_application.sp[0].application_id
}

resource "azurerm_role_assignment" "sp" {
  count                = length(var.role_scopes)
  role_definition_name = var.role_name
  principal_id         = var.create_for_rbac == true ? azuread_service_principal.sp[0].object_id : var.object_id
  scope                = var.role_scopes[count.index]
}

resource "azuread_service_principal_password" "sp" {
  count                = local.sps_to_create
  service_principal_id = azuread_service_principal.sp[0].object_id
  value                = local.sp_password
  end_date_relative    = var.sp_pwd_end_date_relative

  lifecycle {
    ignore_changes = all
  }
}
