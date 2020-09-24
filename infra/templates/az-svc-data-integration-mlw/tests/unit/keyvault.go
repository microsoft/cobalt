package test

import (
	"fmt"
	"sort"
	"testing"

	"github.com/microsoft/terratest-abstraction/unit"
)

func appendKeyVaultTests(t *testing.T, description unit.ResourceDescription) {
	kvBasicExpectations(t, description)
	//kvAccessPolicyExpectations(t, description)
	kvSecretExpectations(t, description)
}

func kvBasicExpectations(t *testing.T, description unit.ResourceDescription) {
	k1 := "module.keyvault.azurerm_key_vault.keyvault"
	e1 := asMap(t, `{
	   "sku_name":    "standard"
	}`)
	description[k1] = e1
}

func kvSecretExpectations(t *testing.T, description unit.ResourceDescription) {
	expectedKeys := []string{
		"appinsights-key",
		"mlw-appinsights-key",
		"sys-storage-account-key",
		"app-storage-account-key",
		"app-sp-tenant-id",
		"aad-client-id",
		"app-sp-username",
		"app-sp-password",
		"cosmos-endpoint",
		"cosmos-primary-key",
		"cosmos-connection",
		"function-app-key",
	}

	// The unit test fixture will expect these secrets to match ordinals returned by terraform, which sorts by name
	sort.Strings(expectedKeys)
	for index, value := range expectedKeys {
		key := fmt.Sprintf("module.keyvault_secrets.azurerm_key_vault_secret.secret[%v]", index)
		val := asMap(t, fmt.Sprintf(`{"name": "%s"}`, value))
		description[key] = val
	}
}

func kvAccessPolicyExpectations(t *testing.T, description unit.ResourceDescription) {
	e1 := asMap(t, `{
       "certificate_permissions": ["get", "list"],
       "secret_permissions": ["get", "list"],
       "key_permissions": ["get", "list"]
    }`)
	k1 := "module.app_service_keyvault_access_policy.azurerm_key_vault_access_policy.keyvault[0]"
	description[k1] = e1
}
