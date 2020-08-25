package integration

import (
	"testing"

	"github.com/microsoft/cobalt/test-harness/terratest-extensions/modules/azure"
	"github.com/microsoft/terratest-abstraction/integration"
	"github.com/stretchr/testify/require"
)

// healthCheck - Asserts that the deployment was successful.
func healthCheck(t *testing.T, provisionState string) {
	require.Equal(t, "Succeeded", provisionState, "The deployment hasn't succeeded.")
}

// validateDeployment - Asserts that ACR deployment was successful
func validateDeployment(
	t *testing.T,
	output integration.TerraformOutput,
	subscriptionID string,
	resourceGroupNameOutput string,
	containerRegistryNameOutput string) {

	// Obtain the container registry output name
	acrName := output[containerRegistryNameOutput].(string)

	// Obtain the registry structure
	resourceGroupName := output[resourceGroupNameOutput].(string)

	require.NotEmpty(t, resourceGroupName, "Resource Group Name not returned.")
	require.NotEmpty(t, acrName, "Registry Name not returned.")

	// Get Registry
	registry, err := azure.ACRRegistryE(subscriptionID, resourceGroupName, acrName)

	if err != nil {
		t.Fatal(err)
	}

	// Get registry's properties
	properties := registry.RegistryProperties
	// check that the registry was provisioned
	healthCheck(t, string(properties.ProvisioningState))

	// check if the admin settings were disabled
	isAdminEnabled := properties.AdminUserEnabled
	require.Equal(t, false, *isAdminEnabled, "The admin user identity must be disabled for this registry.")

}

// InspectContainerRegistryOutputs - Runs test assertions to validate that the module outputs are valid.
func InspectContainerRegistryOutputs(subscriptionID string,
	resourceGroupNameOutput string,
	containerRegistryNameOutput string) func(t *testing.T, output integration.TerraformOutput) {
	return func(t *testing.T, output integration.TerraformOutput) {
		validateDeployment(t, output, subscriptionID,
			resourceGroupNameOutput,
			containerRegistryNameOutput)
	}
}
