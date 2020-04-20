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
  type        = string
  description = "The name of the Key Vault where the Certificate should be created."
}

variable "resource_group_name" {
  type        = string
  description = "Default resource group name that the network will be created in."
}

variable "key_vault_cert_name" {
  description = "Name of the certifacte to create"
  type        = string
  default     = "pfx-certificate"
}

variable "key_vault_cert_alt_names" {
  type        = list(string)
  description = "A list of alternative DNS names (FQDNs) identified by the Certificate. Changing this forces a new resource to be created."
  default     = [""]
}

variable "key_vault_content_type" {
  type        = string
  description = " The Content-Type of the Certificate, such as application/x-pkcs12 for a PFX or application/x-pem-file for a PEM. Changing this forces a new resource to be created."
  default     = "application/x-pkcs12"
}

variable "key_vault_cert_import_filepath" {
  type        = string
  description = "The base64-encoded certificate file path. Changing this forces a new resource to be created."
  default     = ""
}

variable "key_vault_cert_subject" {
  type        = string
  description = "The Certificate's Subject. Changing this forces a new resource to be created."
  default     = ""
}

variable "key_vault_cert_validity_months" {
  type        = number
  description = "The Certificates Validity Period in Months."
  default     = 12
}

variable "key_vault_cert_days_before_expiry" {
  type        = number
  description = "The number of days before the Certificate expires that the action associated with this Trigger should run."
  default     = 30
}

