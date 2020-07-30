package integration

import (
	"os"
	"testing"

	"github.com/microsoft/cobalt/infra/modules/providers/azure/function-app/tests"
	"github.com/microsoft/terratest-abstraction/integration"
)

var subscription = os.Getenv("ARM_SUBSCRIPTION_ID")

//TestFunctionApp Integration test case
func TestFunctionApp(t *testing.T) {
	testFixture := integration.IntegrationTestFixture{
		GoTest:                t,
		TfOptions:             tests.FunctionAppTFOptions,
		ExpectedTfOutputCount: 6,
		TfOutputAssertions: []integration.TerraformOutputValidation{
			VerifyCreatedFunctionApp(subscription,
				"azure_functionapp_name",
			),
		},
	}
	integration.RunIntegrationTests(&testFixture)
}
