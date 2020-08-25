package integration

import (
	"fmt"
	"os"
	"testing"

	"github.com/microsoft/cobalt/infra/modules/providers/azure/container-registry/tests"
	"github.com/microsoft/terratest-abstraction/integration"
)

const outputVariableCount int = 3

var subscription_id = os.Getenv("ARM_SUBSCRIPTION_ID")

func TestServiceDeployment(t *testing.T) {
	if tests.name == "" {
		t.Fatal(fmt.Errorf("Container Registry Name was not specified. Are all the required environment variables set?"))
	}

	testFixture := integration.IntegrationTestFixture{
		GoTest:                t,
		TfOptions:             tests.StorageTFOptions,
		ExpectedTfOutputCount: outputVariableCount,
		TfOutputAssertions: []integration.TerraformOutputValidation{
			InspectContainerRegistryOutputs(subscription_id, "resource_group_name", "container_registry_name"),
		},
	}
	integration.RunIntegrationTests(&testFixture)
}
