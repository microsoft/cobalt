package integration

import (
	"fmt"
	"testing"

	"github.com/Azure/azure-sdk-for-go/services/containerregistry/mgmt/2017-10-01/containerregistry"
	"github.com/microsoft/cobalt/test-harness/infratests"
	"github.com/microsoft/cobalt/test-harness/terratest-extensions/modules/azure"
	"github.com/stretchr/testify/require"
)

// Verifies that the ACR instance deployed is properly isolated within the VNET
func verifyVnetIntegrationForACR(goTest *testing.T, output infratests.TerraformOutput) {
	appDevResourceGroup := output["app_dev_resource_group"].(string)
	acrName := output["acr_name"].(string)
	acrACLs := azure.ACRNetworkAcls(goTest, adminSubscription, appDevResourceGroup, acrName)
	verifyVnetSubnetWhitelistForACR(goTest, acrACLs)
}

// Verify that only the correct subnets have access to the ACR
func verifyVnetSubnetWhitelistForACR(goTest *testing.T, acrACLs *containerregistry.NetworkRuleSet) {
	subnetIDs := azure.VnetSubnetsList(goTest, adminSubscription, aseResourceGroup, aseVnetName)

	// The default action should be to deny all traffic
	require.Equal(
		goTest,
		containerregistry.DefaultActionDeny,
		acrACLs.DefaultAction,
		fmt.Sprintf("Expected default option of %s but got %s", containerregistry.DefaultActionDeny, acrACLs.DefaultAction))

	subnetsWithACRAccess := make([]string, len(*acrACLs.VirtualNetworkRules))
	for i, rule := range *acrACLs.VirtualNetworkRules {
		subnetsWithACRAccess[i] = *rule.VirtualNetworkResourceID
	}

	// The subnets within the VNET should be the only networks with access to the resource
	requireEqualIgnoringOrderAndCase(goTest, subnetIDs, subnetsWithACRAccess)
}
