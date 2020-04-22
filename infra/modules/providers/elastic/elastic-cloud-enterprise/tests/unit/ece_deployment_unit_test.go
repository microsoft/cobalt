package unit

import (
	"testing"

	"github.com/microsoft/cobalt/infra/modules/providers/elastic/elastic-cloud-enterprise/tests"
	"github.com/microsoft/cobalt/test-harness/infratests"
)

/**
 * Note: this module is currently implemented using the following constructs:
 *	- `null_resource` with a `local-exec` provisioner
 *	- `external` data references
 *
 * These constructs all defer work to an underling command or script and do not
 * expose anythign useful to the terraform core library. This results in a
 * Terraform plan output with little useful information in it. Because of this,
 * the unit test for this module will not be a very in-depth test.
 *
 * Most of the value of testing this module is in the form of integration tests,
 * which are not in the scope of this specific test.
 */
func TestECEDeployment_Unit(t *testing.T) {
	testFixture := infratests.UnitTestFixture{
		GoTest:                          t,
		TfOptions:                       tests.ECETFOptions,
		ExpectedResourceCount:           4,
		ExpectedResourceAttributeValues: infratests.ResourceDescription{},
	}

	infratests.RunUnitTests(&testFixture)
}
