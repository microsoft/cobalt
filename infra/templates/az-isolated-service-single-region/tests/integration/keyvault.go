package integration

import (
	"fmt"
	"testing"

	"github.com/Azure/azure-sdk-for-go/services/keyvault/mgmt/2018-02-14/keyvault"
	"github.com/microsoft/cobalt/test-harness/infratests"
	"github.com/microsoft/cobalt/test-harness/terratest-extensions/modules/azure"
	"github.com/stretchr/testify/require"
)

// Verifies that the Key Vault instance deployed is properly isolated within the VNET
func verifyVnetIntegrationForKeyVault(goTest *testing.T, output infratests.TerraformOutput) {
	appDevResourceGroup := output["app_dev_resource_group"].(string)
	vaultName := output["keyvault_name"].(string)
	keyVaultACLs := azure.KeyVaultNetworkAcls(goTest, adminSubscription, appDevResourceGroup, vaultName)
	verifyVnetSubnetWhitelistForKeyvault(goTest, keyVaultACLs)
	verifyIPWhitelistForKeyvault(goTest, keyVaultACLs)
}

// Verify that only the correct IPs have access to the Keyvault
func verifyIPWhitelistForKeyvault(goTest *testing.T, keyVaultACLs *keyvault.NetworkRuleSet) {
	// Refer to the documentation in `terraform.tfvars` to understand why this IP address
	// is whitelisted
	// Terraform seems to be adding a CIDR block with the IPs provided, for example the expected IP below of 1.1.1.1 would be 1.1.1.1/32 in the CIDR format.
	expectedIpsWithKeyvaultAccess := []string{"1.1.1.1/32"}
	ipsWithKeyvaultAccess := make([]string, len(*keyVaultACLs.IPRules))
	for i, rule := range *keyVaultACLs.IPRules {
		ipsWithKeyvaultAccess[i] = *rule.Value
	}

	requireEqualIgnoringOrderAndCase(goTest, ipsWithKeyvaultAccess, expectedIpsWithKeyvaultAccess)
}

// Verify that only the correct subnets have access to the ACR
func verifyVnetSubnetWhitelistForKeyvault(goTest *testing.T, keyVaultACLs *keyvault.NetworkRuleSet) {
	subnetIDs := azure.VnetSubnetsList(goTest, adminSubscription, aseResourceGroup, aseVnetName)
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

	subnetsWithKeyVaultAccess := make([]string, len(*keyVaultACLs.VirtualNetworkRules))
	for i, rule := range *keyVaultACLs.VirtualNetworkRules {
		subnetsWithKeyVaultAccess[i] = *rule.ID
	}

	// The subnets within the VNET should be the only networks with access to the resource
	requireEqualIgnoringOrderAndCase(goTest, subnetIDs, subnetsWithKeyVaultAccess)
}
