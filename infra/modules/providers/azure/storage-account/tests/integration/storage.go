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
