package integration

import (
	"os"
	"testing"

	"github.com/microsoft/cobalt/infra/modules/providers/azure/cosmosdb/tests"
	"github.com/microsoft/terratest-abstraction/integration"
)

var subscriptionID = os.Getenv("ARM_SUBSCRIPTION_ID")

func TestCosmosDeployment(t *testing.T) {

	testFixture := integration.IntegrationTestFixture{
		GoTest:                t,
		TfOptions:             tests.CosmosDbTFOptions,
		ExpectedTfOutputCount: 3,
		TfOutputAssertions: []integration.TerraformOutputValidation{
			InspectCosmosDBModuleOutputs("properties"),
			InspectProvisionedCosmosDBAccount(subscriptionID, "resource_group_name", "account_name", "properties"),
		},
	}
	integration.RunIntegrationTests(&testFixture)
}
