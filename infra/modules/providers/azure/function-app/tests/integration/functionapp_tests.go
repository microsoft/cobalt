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

// VerifyCreatedFunctionApp - validate the created function App
func VerifyCreatedFunctionApp(subscriptionID string, functionAppOutputName string) func(goTest *testing.T, output integration.TerraformOutput) {
	return func(goTest *testing.T, output integration.TerraformOutput) {

		expectedFunctionAppName := output[functionAppOutputName].([]interface{})

		actualFunctionAppNameFromAzure := azure.GetAllAppList(
			goTest,
			subscriptionID)

		require.Subset(goTest, *actualFunctionAppNameFromAzure, expectedFunctionAppName, "The function App does not exist")
	}
}
