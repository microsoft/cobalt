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
	"encoding/json"
	"testing"

	"github.com/microsoft/cobalt/infra/modules/providers/azure/storage-account/tests"
	"github.com/microsoft/cobalt/test-harness/infratests"
)

var resourceCount = 2

func asMap(t *testing.T, jsonString string) map[string]interface{} {
	var theMap map[string]interface{}
	if err := json.Unmarshal([]byte(jsonString), &theMap); err != nil {
		t.Fatal(err)
	}
	return theMap
}

func TestStorageDeployment_Unit(t *testing.T) {

	expectedResult := asMap(t, `{
    "account_kind": "StorageV2",
    "account_replication_type": "LRS",
    "account_tier": "Standard",
    "account_encryption_source": "Microsoft.Storage"
  }`)

	expectedContainerResult := asMap(t, `{
	  "container_access_type": "private",
	  "name": "`+tests.ContainerName+`"
	}`)

	testFixture := infratests.UnitTestFixture{
		GoTest:                t,
		TfOptions:             tests.StorageTFOptions,
		ExpectedResourceCount: resourceCount,
		ExpectedResourceAttributeValues: infratests.ResourceDescription{
			"azurerm_storage_account.main":      expectedResult,
			"azurerm_storage_container.main[0]": expectedContainerResult,
		},
	}

	infratests.RunUnitTests(&testFixture)
}
