//  Copyright © Microsoft Corporation
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

package unit

import (
	"github.com/microsoft/cobalt/infra/modules/providers/elastic/elastic-cloud-enterprise/tests"
	"github.com/microsoft/cobalt/test-harness/infratests"
	"testing"
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
