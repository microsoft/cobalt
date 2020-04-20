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

variable "elasticsearch" {
  description = "Settings for defining a cluster"
  type = object({
    version = string
    cluster_topology = object({
      memory_per_node     = number
      node_count_per_zone = number
      zone_count          = number
      node_type = object({
        data   = bool
        ingest = bool
        master = bool
        ml     = bool
      })
    })
  })
}

variable "name" {
  description = "The name of the deployment"
  type        = string
}

variable "coordinator_url" {
  description = "The coordinator URL"
  type        = string
}

variable "auth_token" {
  description = "Authentication token"
  type        = string
}

variable "auth_type" {
  description = "Type of auth to use. Options are 'ApiKey' or 'Basic'"
  type        = string
  default     = "ApiKey"
}