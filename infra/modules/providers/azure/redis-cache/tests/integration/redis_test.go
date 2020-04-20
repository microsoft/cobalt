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

	"github.com/microsoft/cobalt/infra/modules/providers/azure/redis-cache/tests"
	"github.com/microsoft/cobalt/test-harness/infratests"
)

func TestRedisDeployment(t *testing.T) {
	if tests.RedisName == "" {
		t.Fatal(fmt.Errorf("tests.RedisName was not specified. Are all the required environment variables set?"))
	}

	if tests.ResourceGroupName == "" {
		t.Fatal(fmt.Errorf("tests.ResourceGroupName was not specified. Are all the required environment variables set?"))
	}

	testFixture := infratests.IntegrationTestFixture{
		GoTest:                t,
		TfOptions:             tests.RedisOptions,
		ExpectedTfOutputCount: 6,
		TfOutputAssertions: []infratests.TerraformOutputValidation{
			InspectProvisionedCache("name", "resource_group_name"),
			CheckRedisWriteOperations("hostname", "primary_access_key", "ssl_port"),
		},
	}
	infratests.RunIntegrationTests(&testFixture)
}
