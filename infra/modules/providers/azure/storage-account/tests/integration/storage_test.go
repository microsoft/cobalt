package integration

import (
	"fmt"
	"testing"

	"github.com/microsoft/cobalt/infra/modules/providers/azure/storage-account/tests"
	"github.com/microsoft/cobalt/test-harness/infratests"
)

var outputVariableCount = 7

func TestServiceDeployment(t *testing.T) {
	if tests.ResourceGroupName == "" {
		t.Fatal(fmt.Errorf("tests.ResourceGroupName was not specified. Are all the required environment variables set?"))
	}

	if tests.ContainerName == "" {
		t.Fatal(fmt.Errorf("Container Name was not specified. Are all the required environment variables set?"))
	}

	testFixture := infratests.IntegrationTestFixture{
		GoTest:                t,
		TfOptions:             tests.StorageTFOptions,
		ExpectedTfOutputCount: outputVariableCount,
		TfOutputAssertions: []infratests.TerraformOutputValidation{
			InspectStorageAccount("name", "containers", "resource_group_name"),
		},
	}
	infratests.RunIntegrationTests(&testFixture)
}
