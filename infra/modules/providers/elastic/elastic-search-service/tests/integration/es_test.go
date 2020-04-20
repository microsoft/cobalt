package integration

import (
	"fmt"
	"testing"

	"github.com/microsoft/cobalt/infra/modules/providers/elastic/elastic-search-service/tests"
	"github.com/microsoft/cobalt/test-harness/infratests"
)

func TestESSDeployment(t *testing.T) {
	if tests.ESVersion == "" {
		t.Fatal(fmt.Errorf("tests.ESVersion was not specified. Are all the required environment variables set?"))
	}
	testFixture := infratests.IntegrationTestFixture{
		GoTest:                t,
		TfOptions:             tests.ECETFOptions,
		ExpectedTfOutputCount: 1,
		TfOutputAssertions: []infratests.TerraformOutputValidation{
			CheckClusterHealth("cluster_properties"),
			CheckClusterVersion("cluster_properties"),
			CheckClusterIndexing("cluster_properties"),
		},
	}
	infratests.RunIntegrationTests(&testFixture)
}
