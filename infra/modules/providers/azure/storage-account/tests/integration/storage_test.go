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
