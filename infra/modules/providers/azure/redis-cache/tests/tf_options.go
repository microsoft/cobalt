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

// RedisName the redis cache name
var RedisName = os.Getenv("CACHE_NAME")

// ResourceGroupName the name of the resource group
var ResourceGroupName = os.Getenv("RESOURCE_GROUP_NAME")

// RedisOptions terraform options used for redis integration testing
var RedisOptions = &terraform.Options{
	TerraformDir: "../../",
	Upgrade:      true,
	Vars: map[string]interface{}{
		"name":                RedisName,
		"resource_group_name": ResourceGroupName,
	},
}
