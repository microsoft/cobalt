package test

import (
	"fmt"
	"github.com/Azure/azure-sdk-for-go/services/keyvault/mgmt/2018-02-14/keyvault"
	httpClient "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/microsoft/cobalt/test-harness/infratests"
	"github.com/microsoft/cobalt/test-harness/terratest-extensions/modules/azure"
	"github.com/stretchr/testify/require"
	"os"
	"strings"
	"testing"
	"time"
)

var region = "eastus2"

// see note about static workspace in test case below
var workspace = "cobalt-isolated-testing"

var adminSubscription = os.Getenv("TF_VAR_ase_subscription_id")
var aseName = os.Getenv("TF_VAR_ase_name")
var aseResourceGroup = os.Getenv("TF_VAR_ase_resource_group")

var tfOptions = &terraform.Options{
	TerraformDir: "../../",
	Upgrade:      true,
	Vars: map[string]interface{}{
		"resource_group_location": region,
		"ase_subscription_id":     adminSubscription,
		"ase_name":                aseName,
		"ase_resource_group":      aseResourceGroup,
		"app_service_name": map[string]interface{}{
			"cobalt-backend-api-1": "appsvcsample/static-site:latest",
			"cobalt-backend-api-2": "appsvcsample/static-site:latest",
		},
	},
	BackendConfig: map[string]interface{}{
		"storage_account_name": os.Getenv("TF_VAR_remote_state_account"),
		"container_name":       os.Getenv("TF_VAR_remote_state_container"),
	},
}

// Validates that the service responds with HTTP 200 status code. A retry strategy
// is used because it may take some time for the application to finish standing up.
func httpGetRespondsWith200(goTest *testing.T, output infratests.TerraformOutput) {
	maxRetries := 20
	timeBetweenRetries := 2 * time.Second
	expectedResponse := "Hello App Service!"

	for _, hostname := range output["fqdns"].([]interface{}) {
		err := httpClient.HttpGetWithRetryWithCustomValidationE(
			goTest,
			hostname.(string),
			maxRetries,
			timeBetweenRetries,
			func(status int, content string) bool {
				return status == 200 && strings.Contains(content, expectedResponse)
			},
		)
		require.NoError(goTest, err)
	}
}

// Verifies that the Key Vault instance deployed is properly isolated within the VNET
func verifyVnetIntegrationForKeyVault(goTest *testing.T, output infratests.TerraformOutput) {
	vaultResourceGroup := output["app_dev_resource_group"].(string)
	vaultName := output["keyvault_name"].(string)
	keyVaultACLs := azure.KeyVaultNetworkAcls(goTest, adminSubscription, vaultResourceGroup, vaultName)
	subnetIDs := azure.VnetSubnetsList(goTest, adminSubscription, aseResourceGroup, os.Getenv("TF_VAR_ase_vnet_name"))

	// No azure services should have bypass rules that allow them to circumvent the VNET isolation
	require.Equal(
		goTest,
		keyVaultACLs.Bypass, keyvault.None,
		fmt.Sprintf("Expected bypass option of %s but got %s", keyvault.None, keyVaultACLs.Bypass))

	// The default action should be to deny all traffic
	require.Equal(
		goTest,
		keyVaultACLs.DefaultAction,
		keyvault.Deny, fmt.Sprintf("Expected default option of %s but got %s", keyvault.Deny, keyVaultACLs.DefaultAction))

	// The subnets within the VNET should be the only networks with access to the resource
	for _, subnetID := range subnetIDs {
		found := false
		for _, virtualNetworkRule := range *keyVaultACLs.VirtualNetworkRules {
			if strings.ToLower(subnetID) == strings.ToLower(*virtualNetworkRule.ID) {
				found = true
			}
		}
		require.True(goTest, found, fmt.Sprintf("Subnet %s should have access to keyvault but it did not", subnetID))
	}

	// There should the same number of network rules as there are subnets in the VNET
	require.Equal(
		goTest,
		len(*keyVaultACLs.VirtualNetworkRules),
		len(subnetIDs),
		fmt.Sprintf("Expected %d subnets with access to keyvault but found %d", len(subnetIDs), len(*keyVaultACLs.VirtualNetworkRules)))
}

func TestAzureSimple(t *testing.T) {
	// Note: creating an App Service Plan configured with an Isolated SKU can take > 1.5
	// hours. In order to prevent a very long test cycle this test uses a static environment
	// that lives beyond the lifetime of this test. This is achieved using the
	// `SkipCleanupAfterTest` option.
	//
	// Be aware that this breaks testing isolation such that it is
	// possible that the environment is messed up by a test, which causes future tests
	// to fail for unrelated reasons.
	testFixture := infratests.IntegrationTestFixture{
		GoTest:                t,
		TfOptions:             tfOptions,
		Workspace:             workspace,
		SkipCleanupAfterTest:  true,
		ExpectedTfOutputCount: 7,
		ExpectedTfOutput: infratests.TerraformOutput{
			"fqdns": []string{
				"http://cobalt-backend-api-1-" + workspace + "." + aseName + ".p.azurewebsites.net",
				"http://cobalt-backend-api-2-" + workspace + "." + aseName + ".p.azurewebsites.net",
			},
			"keyvault_name": "isolated-service-cob-kv",
		},
		TfOutputAssertions: []infratests.TerraformOutputValidation{
			httpGetRespondsWith200,
			verifyVnetIntegrationForKeyVault,
		},
	}

	azure.CliServicePrincipalLogin(t)
	infratests.RunIntegrationTests(&testFixture)
}
