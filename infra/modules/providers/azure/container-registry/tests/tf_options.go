package tests

import (
	"github.com/gruntwork-io/terratest/modules/terraform"
	"os"
)

var container_registry_name = os.Getenv("TF_VAR_container_registry_name")
var resource_group_name = os.Getenv("TF_VAR_resource_group_name")

//Sets variable values for module level testing
var RegistryTFOptions = &terraform.Options{
	TerraformDir: ".",
	Upgrade:      true,
	Vars: map[string]interface{}{
		"resource_group_name":      resource_group_name,
		"container_registery_name": container_registry_name,
	},
	BackendConfig: map[string]interface{}{
		"storage_account_name": os.Getenv("TF_VAR_remote_state_account"),
		"container_name":       os.Getenv("TF_VAR_remote_state_container"),
	},
}
