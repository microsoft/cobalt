package tests

import (
	"os"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

// ResourceGroupName - The Resource Group Name
var ResourceGroupName = os.Getenv("RESOURCE_GROUP_NAME")

// VnetName - The name of vnet
var VnetName = os.Getenv("VNET_NAME")

// SubnetName - The name of subnet
var SubnetName = os.Getenv("SUBNET_NAME")

// AddressSpace -
var AddressSpace = os.Getenv("ADDRESS_SPACE")

// AddressPrefix -
var AddressPrefix = os.Getenv("ADDRESS_PREFIX")

// NetworkTFOptions common terraform options used for unit and integration testing
var NetworkTFOptions = &terraform.Options{
	TerraformDir: "../../",
	VarFiles:     []string{"./tests/test.tfvars"},
}
