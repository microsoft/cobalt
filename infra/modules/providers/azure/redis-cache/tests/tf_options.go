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
