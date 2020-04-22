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
