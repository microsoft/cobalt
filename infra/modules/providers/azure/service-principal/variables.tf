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

variable "role_name" {
  description = "The name of the role definition to assign a service principle too."
  type        = string
}

variable "role_scopes" {
  description = "The scopes at which the Role Assignment applies too, such as [/subscriptions/0b1f6471-1bf0-4dda-aec3-111122223333]"
  type        = list(string)
}

variable "create_for_rbac" {
  description = "Create a new Service Principle"
  type        = bool
  default     = false
}

variable "display_name" {
  description = "Display name of the AD application"
  type        = string
  default     = ""
}

variable "object_id" {
  description = "Object Id of the service principle to assign a role"
  type        = string
  default     = ""
}

variable "sp_pwd_end_date_relative" {
  description = "A relative duration for which the Password is valid until"
  type        = string
  default     = "17520h" #2 Years
}