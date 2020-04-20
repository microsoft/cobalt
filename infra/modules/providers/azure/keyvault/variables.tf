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

variable "keyvault_name" {
  description = "Name of the keyvault to create"
  type        = string
  default     = "spkeyvault"
}

variable "keyvault_sku" {
  description = "SKU of the keyvault to create"
  type        = string
  default     = "standard"
}

variable "resource_group_name" {
  type        = string
  description = "Default resource group name that the network will be created in."
}

variable "keyvault_key_permissions" {
  description = "Permissions that the service principal has for accessing keys from KeyVault"
  type        = list(string)
  default     = ["create", "delete", "get"]
}

variable "keyvault_secret_permissions" {
  description = "Permissions that the service principal has for accessing secrets from KeyVault"
  type        = list(string)
  default     = ["set", "delete", "get", "list"]
}

variable "keyvault_certificate_permissions" {
  description = "Permissions that the service principal has for accessing certificates from KeyVault"
  type        = list(string)
  default     = ["create", "delete", "get", "list"]
}

variable "resource_tags" {
  description = "Map of tags to apply to taggable resources in this module.  By default the taggable resources are tagged with the name defined above and this map is merged in"
  type        = map(string)
  default     = {}
}

variable "subnet_id_whitelist" {
  description = "If supplied this represents the subnet IDs that should be allowed to access this resource"
  type        = list(string)
  default     = []
}

variable "resource_ip_whitelist" {
  description = "A list of IPs and/or IP ranges that should have access to the provisioned keyvault"
  type        = list(string)
  default     = []
}
