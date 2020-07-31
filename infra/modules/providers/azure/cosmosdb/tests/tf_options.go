package tests

import (
	"os"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

// ResourceGroupName - The Resource Group Name
var ResourceGroupName = os.Getenv("RESOURCE_GROUP_NAME")

// CosmosDbTFOptions common terraform options used for unit and integration testing
var CosmosDbTFOptions = &terraform.Options{
	TerraformDir: "../../",
	VarFiles:     []string{"./tests/test.tfvars"},
}
