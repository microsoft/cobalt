package integraton

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

// VerifyCreatedDataFactory - validate the created data factory
func VerifyCreatedDataFactory(subscriptionID, resourceGroupOutputName, dataFactoryOutputName string) func(goTest *testing.T, output integration.TerraformOutput) {
	return func(goTest *testing.T, output integration.TerraformOutput) {

		dataFactory := output[dataFactoryOutputName].(string)
		resourceGroup := output[resourceGroupOutputName].(string)

		dataFactoryNameFromAzure := azure.GetDataFactoryNameByResourceGroup(
			goTest,
			subscriptionID,
			resourceGroup)

		require.Equal(goTest, dataFactoryNameFromAzure, dataFactory, "The data factory does not exist")
	}
}

// VerifyCreatedPipeline - validate the pipeline name for the created data factory
func VerifyCreatedPipeline(subscriptionID, resourceGroupOutputName, dataFactoryOutputName, pipelineOutputName string) func(goTest *testing.T, output integration.TerraformOutput) {
	return func(goTest *testing.T, output integration.TerraformOutput) {
		pipelineNameFromOutput := output[pipelineOutputName].(string)

		dataFactory := output[dataFactoryOutputName].(string)
		resourceGroup := output[resourceGroupOutputName].(string)

		pipelineNameFromAzure := azure.GetPipeLineNameByDataFactory(
			goTest,
			subscriptionID,
			resourceGroup,
			dataFactory)

		require.Equal(goTest, pipelineNameFromAzure, pipelineNameFromOutput, "The pipeline does not exist in the data factory")
	}
}

// VerifyCreatedDataset - validate the SQL dataset for the created pipeline
func VerifyCreatedDataset(subscriptionID, resourceGroupOutputName, dataFactoryOutputName, datasetOutputID string) func(goTest *testing.T, output integration.TerraformOutput) {
	return func(goTest *testing.T, output integration.TerraformOutput) {
		datasetIDFromOutput := output[datasetOutputID].(string)

		dataFactory := output[dataFactoryOutputName].(string)
		resourceGroup := output[resourceGroupOutputName].(string)

		datasetIDFromAzure := azure.ListDatasetIDByDataFactory(goTest,
			subscriptionID,
			resourceGroup,
			dataFactory)

		require.Contains(goTest, *datasetIDFromAzure, datasetIDFromOutput, "The dataset does not exist")
	}
}

// VerifyCreatedLinkedService - validate the SQL dataset for the created pipeline
func VerifyCreatedLinkedService(subscriptionID, resourceGroupOutputName, dataFactoryOutputName, linkedServiceIDOutputName string) func(goTest *testing.T, output integration.TerraformOutput) {
	return func(goTest *testing.T, output integration.TerraformOutput) {
		linkedServiceIDFromOutput := output[linkedServiceIDOutputName].(string)

		dataFactory := output[dataFactoryOutputName].(string)
		resourceGroup := output[resourceGroupOutputName].(string)

		linkedServiceIDFromAzure := azure.ListLinkedServicesIDByDataFactory(goTest,
			subscriptionID,
			resourceGroup,
			dataFactory)

		require.Contains(goTest, *linkedServiceIDFromAzure, linkedServiceIDFromOutput, "The Linked Servicee does not exist")
	}
}
