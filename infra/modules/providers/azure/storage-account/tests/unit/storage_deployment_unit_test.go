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
