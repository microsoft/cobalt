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

# Naming Items (required)

variable "name" {
  description = "The name of the storage account service."
  type        = string
}

variable "container_names" {
  description = "The list of storage container names to create. Names must be unique per storage account."
  type        = list(string)
}

variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
}


# Tier Items (optional)

variable "performance_tier" {
  description = "Determines the level of performance required."
  type        = string
  default     = "Standard"
}

variable "kind" {
  description = "Storage account types that determine available features and pricing of Azure Storage. Use StorageV2 when possible."
  type        = string
  default     = "StorageV2"
}

variable "replication_type" {
  description = "Defines the type of replication to use for this storage account. Valid options are LRS*, GRS, RAGRS and ZRS."
  type        = string
  default     = "LRS"
}


# Configuration Items (optional)

variable "https" {
  description = "Boolean flag which forces HTTPS in order to ensure secure connections."
  type        = bool
  default     = true
}

variable "encryption_source" {
  description = "Determines the source that will manage encryption for the storage account. Valid options are Microsoft.Storage and Microsoft.Keyvault."
  type        = string
  default     = "Microsoft.Storage"
}


# General Items (optional)

variable "resource_tags" {
  description = "Map of tags to apply to taggable resources in this module. By default the taggable resources are tagged with the name defined above and this map is merged in"
  type        = map(string)
  default     = {}
}
