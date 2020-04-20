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

package tests

import (
	"os"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

// StorageAccount - The Storage Account Name
var StorageAccount = os.Getenv("STORAGE_ACCOUNT_NAME")

// ContainerName - The Container Name
var ContainerName = os.Getenv("CONTAINER_NAME")

// ResourceGroupName - The Resource Group Name
var ResourceGroupName = os.Getenv("RESOURCE_GROUP_NAME")

// StorageTFOptions common terraform options used for unit and integration testing
var StorageTFOptions = &terraform.Options{
	TerraformDir: "../../",
	Vars: map[string]interface{}{
		"resource_group_name": ResourceGroupName,
		"name":                StorageAccount,
		"container_names": []interface{}{
			ContainerName,
		},
	},
}
