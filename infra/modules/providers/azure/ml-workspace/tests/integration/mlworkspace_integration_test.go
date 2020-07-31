package integration

import (
	"os"
	"testing"

	"github.com/microsoft/cobalt/infra/modules/providers/azure/ml-workspace/tests"
	"github.com/microsoft/terratest-abstraction/integration"
)

var subscription = os.Getenv("ARM_SUBSCRIPTION_ID")
var resorurcegroupname = os.Getenv("RESOURCE_GROUP_NAME")

func TestMLWorkspace(t *testing.T) {
	testFixture := integration.IntegrationTestFixture{
		GoTest:                t,
		TfOptions:             tests.MLWorkspaceTFOptions,
		ExpectedTfOutputCount: 1,
		TfOutputAssertions: []integration.TerraformOutputValidation{
			VerifyCreatedMLworkspace(subscription,
				"resource_group_name",
				"id",
			),
		},
	}
	integration.RunIntegrationTests(&testFixture)
}
