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

// CosmosDBAccountName the name of the Database account in CosmosDB
var cosmosDBAccountName = os.Getenv("COSMOSDB_ACCOUNT_NAME")

// PrimaryReplicaLocation the Azure region for the primary replica
var primaryReplicaLocation = os.Getenv("PRIMARY_REPLICA_LOCATION")

// ResourceGroupName the name of the resource group
var resourceGroupName = os.Getenv("RESOURCE_GROUP_NAME")

// CosmosDBOptions terraform options used for cosmos integration testing
var CosmosDBOptions = &terraform.Options{
	TerraformDir: "../../",
	Upgrade:      true,
	Vars: map[string]interface{}{
		"name":                     cosmosDBAccountName,
		"resource_group_name":      resourceGroupName,
		"primary_replica_location": primaryReplicaLocation,
	},
}
