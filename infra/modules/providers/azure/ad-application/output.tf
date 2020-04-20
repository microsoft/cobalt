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

output "azuread_config_data" {
  description = "Output data that pairs azuread names with their application ids."
  value = {
    for azuread in data.azuread_application.auth :
    azuread.name => {
      application_id = azuread.application_id
    }
  }
}

output "azuread_app_ids" {
  description = "Output data that pairs azuread names with their application ids."
  value       = data.azuread_application.auth.*.application_id
}