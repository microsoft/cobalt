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
