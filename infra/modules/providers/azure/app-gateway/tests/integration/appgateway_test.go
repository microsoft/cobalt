package integration

import (
	"testing"

	"github.com/microsoft/cobalt/infra/modules/providers/azure/app-gateway/tests"
	"github.com/microsoft/terratest-abstraction/integration"
)

func TestAppGateway(t *testing.T) {
	testFixture := integration.IntegrationTestFixture{
		GoTest:                t,
		TfOptions:             tests.AppGatewayOptions,
		ExpectedTfOutputCount: 6,
		TfOutputAssertions: []integration.TerraformOutputValidation{
			InspectAppGateway("resource_group_name", "appgateway_name", "keyvault_secret_id"),
		},
	}
	integration.RunIntegrationTests(&testFixture)
}
