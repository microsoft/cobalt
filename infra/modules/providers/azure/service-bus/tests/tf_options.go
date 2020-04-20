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

var listOfTopics []map[string]interface{}
var listOfTopicAuthRules []map[string]interface{}
var listOfSubscriptions []map[string]interface{}
var listOfNSAuthRules []map[string]interface{}

var resourceGroup = os.Getenv("RESOURCE_GROUP_NAME")

// NamespaceName - Namespace name
var NamespaceName = os.Getenv("NAMESPACE_NAME")

// ServicebusTFOptions common terraform options used for unit and integration testing
var ServicebusTFOptions = &terraform.Options{
	TerraformDir: "../../",

	Vars: map[string]interface{}{
		"namespace_name":      NamespaceName,
		"resource_group_name": resourceGroup,
		"sku":                 "Standard",
		"tags":                map[string]string{"source": "terraform"},
		"namespace_authorization_rules": append(listOfNSAuthRules, map[string]interface{}{
			"policy_name": "policy",
			"claims": map[string]string{
				"listen": "true",
				"send":   "true",
				"manage": "false",
			},
		}),
		"topics": append(listOfTopics, map[string]interface{}{
			"subscriptions": append(listOfSubscriptions, map[string]interface{}{
				"name":                                 "sub_test",
				"max_delivery_count":                   1.0,
				"lock_duration":                        "PT5M",
				"forward_to":                           "",
				"dead_lettering_on_message_expiration": "true",
				"filter_type":                          "SqlFilter",
				"sql_filter":                           "color = 'red'",
				"action":                               "",
			}),
			"name":                         "topic_test",
			"default_message_ttl":          "PT30M",
			"enable_partitioning":          "true",
			"requires_duplicate_detection": "true",
			"support_ordering":             "true",
			"authorization_rules": append(listOfTopicAuthRules, map[string]interface{}{
				"policy_name": "policy",
				"claims": map[string]string{
					"listen": "true",
					"send":   "true",
					"manage": "false",
				},
			}),
		}),
	},
}
