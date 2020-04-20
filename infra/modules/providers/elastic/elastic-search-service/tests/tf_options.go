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

// ESVersion the version of Elasticsearch to deploy
var ESVersion = os.Getenv("ELASTIC_VERSION")

// ECETFOptions common terraform options used for unit and integration testing
var ESSTFOptions = &terraform.Options{
	TerraformDir: "../../",
	Vars: map[string]interface{}{
		"name":                        "",
		"auth_type":                   "",
		"auth_token":                  "",
		"cloud":                       "",
		"region":                      "",
		"deployment_template_id":      "",
		"deployment_configuration_id": "",
		"elasticsearch": map[string]interface{}{
			"version": ESVersion,
			"cluster_topology": map[string]interface{}{
				"zone_count":          1,
				"memory_per_node":     1024,
				"node_count_per_zone": 1,
				"node_type": map[string]string{
					"data":   "true",
					"ingest": "true",
					"master": "true",
					"ml":     "false",
				},
			},
		},
	},
}
