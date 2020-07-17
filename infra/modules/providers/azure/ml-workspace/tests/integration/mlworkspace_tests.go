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

// VerifyCreatedMLworkspace - validate the created ML Workspace
func VerifyCreatedMLworkspace(subscriptionID, resourceGroupName, mlWorkSpaceOutputID string) func(goTest *testing.T, output integration.TerraformOutput) {
	return func(goTest *testing.T, output integration.TerraformOutput) {
		mlWorkspace := output[mlWorkSpaceOutputID].(string)
		mlResourceGroup := output[resourceGroupName].(string)

		mlWorkspaceNameFromAzure := azure.GetMLWorkspaceIDByResourceGroup(
			goTest,
			subscriptionID,
			mlResourceGroup)

		require.Equal(goTest, mlWorkspaceNameFromAzure, mlWorkspace, "The machine learning workspace does not exist")
	}
}
