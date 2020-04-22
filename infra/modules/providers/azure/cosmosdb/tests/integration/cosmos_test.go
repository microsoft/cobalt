package integration

import (
	"testing"

	"github.com/microsoft/cobalt/infra/modules/providers/azure/cosmosdb/tests"
	"github.com/microsoft/cobalt/test-harness/infratests"
)

func TestCosmosDeployment(t *testing.T) {

	testFixture := infratests.IntegrationTestFixture{
		GoTest:                t,
		TfOptions:             tests.CosmosDBOptions,
		ExpectedTfOutputCount: 3,
		TfOutputAssertions: []infratests.TerraformOutputValidation{
			InspectCosmosDBModuleOutputs("properties"),
			InspectProvisionedCosmosDBAccount("resource_group_name", "account_name", "properties"),
		},
	}
	infratests.RunIntegrationTests(&testFixture)
}
