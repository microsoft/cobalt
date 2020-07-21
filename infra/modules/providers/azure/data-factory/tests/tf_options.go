package tests

import (
	"os"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

// ResourceGroupName - The Resource Group Name
var ResourceGroupName = os.Getenv("RESOURCE_GROUP_NAME")

// DataFactoryTFOptions common terraform options used for unit and integration testing
var DataFactoryTFOptions = &terraform.Options{
	TerraformDir: "../../",
	VarFiles:     []string{"./tests/test.tfvars"},
}
