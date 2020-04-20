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
	"os"
	"testing"

	"github.com/microsoft/cobalt/test-harness/infratests"
	"github.com/microsoft/cobalt/test-harness/terratest-extensions/modules/azure"
	"github.com/stretchr/testify/assert"
)

var subscription = os.Getenv("ARM_SUBSCRIPTION_ID")

// InspectStorageAccount - Runs a suite of test assertions to validate the list of containers.
func InspectStorageAccount(storageAccountOutputName string, storageContainerOutputName string, resourceGroupOutputName string) func(t *testing.T, output infratests.TerraformOutput) {
	return func(t *testing.T, output infratests.TerraformOutput) {
		resourceGroupName := output[resourceGroupOutputName].(string)
		storageAccountName := output[storageAccountOutputName].(string)
		containerList := output[storageContainerOutputName].(map[string]interface{})

		expectedContainerList := []string{}
		for name := range containerList {
			expectedContainerList = append(expectedContainerList, string(name))
		}

		actualContainerList := []string{}
		for _, container := range *azure.ListAccountContainers(t, subscription, resourceGroupName, storageAccountName) {
			actualContainerList = append(actualContainerList, string(*container.Name))
		}

		assert.ElementsMatch(t, expectedContainerList, actualContainerList, "Container does not exist in the Storage Account")
	}
}
