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

data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

resource "azurerm_storage_account" "main" {
  # required
  name                     = lower(var.name)
  resource_group_name      = data.azurerm_resource_group.main.name
  location                 = data.azurerm_resource_group.main.location
  account_tier             = var.performance_tier
  account_replication_type = var.replication_type

  # optional
  account_kind              = var.kind
  enable_https_traffic_only = var.https
  account_encryption_source = var.encryption_source
  tags                      = var.resource_tags

  # enrolls storage account into azure 'managed identities' authentication
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_storage_container" "main" {
  count                 = length(var.container_names)
  name                  = var.container_names[count.index]
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}
