package integration

import (
	"testing"

	"github.com/microsoft/cobalt/test-harness/terratest-extensions/modules/azure"
	"github.com/microsoft/terratest-abstraction/integration"
	"github.com/stretchr/testify/require"
)

// healthCheck - Asserts that the deployment was successful.
func healthCheck(t *testing.T, provisionState *string) {
	require.Equal(t, "Succeeded", *provisionState, "The deployment hasn't succeeded.")
}

// VerifyCreatedVnets - validate the created subnets
func VerifyCreatedVnets(subscriptionID, resourceGroupName, vnetOutputName string, vnetID string) func(goTest *testing.T, output integration.TerraformOutput) {
	return func(goTest *testing.T, output integration.TerraformOutput) {

		expectedVnetList := output[vnetID].(interface{})

		actualVnetList := azure.VnetsList(goTest, subscriptionID, resourceGroupName)

		require.Subset(goTest, *actualVnetList, expectedVnetList, "Vnet does not exist in the resource group")
	}
}

// VerifyCreatedSubnets - validate the created subnets
func VerifyCreatedSubnets(subscriptionID, resourceGroupName, subnetOutputName string, vnetName string, subnetID string) func(goTest *testing.T, output integration.TerraformOutput) {
	return func(goTest *testing.T, output integration.TerraformOutput) {

		expectedSubnetList := output[subnetID].([]interface{})

		actualSubnetList := azure.VnetSubnetsList(goTest, subscriptionID, resourceGroupName, vnetName)

		require.Subset(goTest, actualSubnetList, expectedSubnetList, "subnet does not exist in the VNet")
	}
}
