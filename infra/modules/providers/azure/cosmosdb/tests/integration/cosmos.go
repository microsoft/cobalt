package integration

import (
	"os"
	"testing"

	"github.com/Azure/azure-sdk-for-go/services/cosmos-db/mgmt/2015-04-08/documentdb"
	httpClient "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/microsoft/cobalt/test-harness/infratests"
	"github.com/microsoft/cobalt/test-harness/terratest-extensions/modules/azure"
	"github.com/stretchr/testify/require"
)

var subscription = os.Getenv("ARM_SUBSCRIPTION_ID")

// validateOutputs - Asserts that expected output values are present.
func validateOutputs(t *testing.T, id string, endpoint string, primaryMasterKey string, connectionStrings []interface{}) {
	require.NotEqual(t, "", id, "ID not returned.")
	require.NotEmpty(t, endpoint, "Endpoint not returned.")
	require.NotEmpty(t, primaryMasterKey, "Master Key missing.")
	require.Equal(t, 4, len(connectionStrings), "Unexpected number of connection strings.")
}

// healthCheck - Asserts that the deployment was successful.
func healthCheck(t *testing.T, provisionState *string) {
	require.Equal(t, "Succeeded", *provisionState, "The deployment hasn't succeeded.")
}

// validateOfferType - Asserts that the fixed offer type "Standard" has not changed.
func validateOfferType(t *testing.T, offerType documentdb.DatabaseAccountOfferType) {
	require.Equal(t, documentdb.Standard, offerType, "The offer type is incorrect.")
}

// validateFailOverPriority - Asserts that the fixed fail over priority '0' has not changed.
func validateFailOverPriority(t *testing.T, failOverPolicy documentdb.FailoverPolicy) {
	require.Equal(t, int32(0), *failOverPolicy.FailoverPriority, "The fail over priority is incorrect.")
}

// getModuleOutputs - Extracts the output variables from property map.
func getModuleOutputs(output infratests.TerraformOutput, outputName string) (id string, endpoint string, primaryMasterKey string, connectionStrings []interface{}) {
	properties := output[outputName].(map[string]interface{})
	cosmosDBProperties := properties["cosmosdb"].(map[string]interface{})

	id = cosmosDBProperties["id"].(string)
	endpoint = cosmosDBProperties["endpoint"].(string)
	primaryMasterKey = cosmosDBProperties["primary_master_key"].(string)
	connectionStrings = cosmosDBProperties["connection_strings"].([]interface{})

	return
}

// validateServiceResponse - Attempt to perform a HTTP request to the live endpoint.
func validateServiceResponse(t *testing.T, output infratests.TerraformOutput, outputName string) {
	_, endpoint, _, _ := getModuleOutputs(output, outputName)
	statusCode, _ := httpClient.HttpGet(t, endpoint)

	require.Equal(t, 401, statusCode, "Service did not respond with the expected Unauthorized status code.")
}

// InspectProvisionedCosmosDBAccount - Runs test assertions to validate that a provisioned CosmosDB Account
// is operational.
func InspectProvisionedCosmosDBAccount(resourceGroupOutputName, accountName, outputName string) func(t *testing.T, output infratests.TerraformOutput) {
	return func(t *testing.T, output infratests.TerraformOutput) {
		resourceGroupName := output[resourceGroupOutputName].(string)
		accountName := output[accountName].(string)
		result := azure.GetCosmosDBAccount(t, subscription, resourceGroupName, accountName)

		healthCheck(t, result.ProvisioningState)

		validateOfferType(t, result.DatabaseAccountOfferType)

		failOverPolicies := *result.FailoverPolicies
		require.Equal(t, 1, len(failOverPolicies))
		validateFailOverPriority(t, failOverPolicies[0])

		validateServiceResponse(t, output, outputName)
	}
}

// InspectCosmosDBModuleOutputs - Runs test assertions to validate that the module outputs are valid.
func InspectCosmosDBModuleOutputs(outputName string) func(t *testing.T, output infratests.TerraformOutput) {
	return func(t *testing.T, output infratests.TerraformOutput) {
		id, endpoint, primaryMasterKey, connectionStrings := getModuleOutputs(output, outputName)
		validateOutputs(t, id, endpoint, primaryMasterKey, connectionStrings)
	}
}
