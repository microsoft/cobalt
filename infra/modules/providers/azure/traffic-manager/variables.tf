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

variable "traffic_manager_profile_name" {
  type = string
}

variable "public_ip_name" {
  type = string
}

variable "endpoint_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "traffic_manager_dns_name" {
  type = string
}

variable "traffic_manager_monitor_protocol" {
  type    = string
  default = "https"
}

variable "traffic_manager_monitor_port" {
  type    = number
  default = 443
}

variable "tags" {
  description = "The tags to associate with the public ip address."
  type        = map(string)

  default = {
    tag1 = ""
    tag2 = ""
  }
}

