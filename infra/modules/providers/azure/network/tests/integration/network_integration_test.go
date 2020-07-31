package integration

import (
	"os"
	"testing"

	"github.com/microsoft/cobalt/infra/modules/providers/azure/network/tests"
	"github.com/microsoft/terratest-abstraction/integration"
)

var subscriptionID = os.Getenv("ARM_SUBSCRIPTION_ID")

func TestNetwork(t *testing.T) {
	testFixture := integration.IntegrationTestFixture{
		GoTest:                t,
		TfOptions:             tests.NetworkTFOptions,
		ExpectedTfOutputCount: 2,
		TfOutputAssertions: []integration.TerraformOutputValidation{
			VerifyCreatedVnets(subscriptionID,
				tests.ResourceGroupName,
				tests.VnetName,
				"virtual_network_id",
			),
			VerifyCreatedSubnets(subscriptionID,
				tests.ResourceGroupName,
				tests.SubnetName,
				tests.VnetName,
				"subnet_ids",
			),
		},
	}
	integration.RunIntegrationTests(&testFixture)
}
