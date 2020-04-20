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

resource "azuread_application" "auth" {
  count                      = length(var.ad_app_config)
  name                       = var.ad_app_config[count.index].app_name
  available_to_other_tenants = var.available_to_other_tenants
  oauth2_allow_implicit_flow = var.oauth2_allow_implicit_flow
  type                       = var.app_type
  reply_urls                 = var.ad_app_config[count.index].reply_urls

  required_resource_access {
    resource_app_id = var.resource_app_id

    resource_access {
      id   = var.resource_role_id
      type = var.resource_access_type
    }
  }

  lifecycle {
    ignore_changes = [
      reply_urls
    ]
    create_before_destroy = true
  }
}

# Gives us access to outputs not directly provided by the resource
data "azuread_application" "auth" {
  count      = length(var.ad_app_config)
  depends_on = [azuread_application.auth]
  object_id  = azuread_application.auth[count.index].object_id
}