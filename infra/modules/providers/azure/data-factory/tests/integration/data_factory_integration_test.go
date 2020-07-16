package integraton

import (
	"os"
	"testing"

	"github.com/microsoft/cobalt/infra/modules/providers/azure/data-factory/tests"
	"github.com/microsoft/terratest-abstraction/integration"
)

var subscription = os.Getenv("ARM_SUBSCRIPTION_ID")

func TestDataFactory(t *testing.T) {
	testFixture := integration.IntegrationTestFixture{
		GoTest:                t,
		TfOptions:             tests.DataFactoryTFOptions,
		ExpectedTfOutputCount: 8,
		TfOutputAssertions: []integration.TerraformOutputValidation{
			VerifyCreatedDataFactory(subscription,
				"resource_group_name",
				"data_factory_name",
			),
			VerifyCreatedPipeline(subscription,
				"resource_group_name",
				"data_factory_name",
				"pipeline_name",
			),
		},
	}
	integration.RunIntegrationTests(&testFixture)
}
