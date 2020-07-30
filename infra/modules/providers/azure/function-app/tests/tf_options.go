package tests

import (
	"os"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

// ResourceGroupName - The Resource Group Name
var ResourceGroupName = os.Getenv("RESOURCE_GROUP_NAME")

//ServicePlanID - The function app service plan id
var ServicePlanID = os.Getenv("APP_SERVICE_PLAN_ID")

// FunctionAppTFOptions common terraform options used for unit and integration testing
var FunctionAppTFOptions = &terraform.Options{
	TerraformDir: "../../",
	VarFiles:     []string{"./tests/test.tfvars"},
}
