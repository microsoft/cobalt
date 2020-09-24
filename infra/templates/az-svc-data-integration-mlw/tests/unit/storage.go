package test

import (
	"testing"

	"github.com/microsoft/terratest-abstraction/unit"
)

func appendStorageTests(t *testing.T, description unit.ResourceDescription) {

	expectedStorageAccount := asMap(t, `{
    "account_kind": "StorageV2",
    "account_replication_type": "LRS",
    "account_tier": "Standard"
	}`)
	description["module.sys_storage_account.azurerm_storage_account.main"] = expectedStorageAccount

	expectedDataPrepStorageAccount := asMap(t, `{
		"account_kind": "StorageV2",
		"account_replication_type": "LRS",
		"account_tier": "Standard"
		}`)
	description["module.app_storage_account.azurerm_storage_account.main"] = expectedDataPrepStorageAccount

	expectedDataPrepStorageContainerList := asMap(t, `{
			"container_access_type":"private",
			"name": "sample"
			}`)
	description["module.app_storage_account.azurerm_storage_container.main[0]"] = expectedDataPrepStorageContainerList
}
