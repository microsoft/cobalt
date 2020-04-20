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

package integration

import (
	"testing"

	"github.com/microsoft/cobalt/infra/modules/providers/azure/cosmosdb/tests"
	"github.com/microsoft/cobalt/test-harness/infratests"
)

func TestCosmosDeployment(t *testing.T) {

	testFixture := infratests.IntegrationTestFixture{
		GoTest:                t,
		TfOptions:             tests.CosmosDBOptions,
		ExpectedTfOutputCount: 3,
		TfOutputAssertions: []infratests.TerraformOutputValidation{
			InspectCosmosDBModuleOutputs("properties"),
			InspectProvisionedCosmosDBAccount("resource_group_name", "account_name", "properties"),
		},
	}
	infratests.RunIntegrationTests(&testFixture)
}
