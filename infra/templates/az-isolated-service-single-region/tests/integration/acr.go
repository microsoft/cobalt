package integration

import (
	"fmt"
	"github.com/Azure/azure-sdk-for-go/services/containerregistry/mgmt/2017-10-01/containerregistry"
	"github.com/microsoft/cobalt/test-harness/infratests"
	"github.com/microsoft/cobalt/test-harness/terratest-extensions/modules/azure"
	"github.com/stretchr/testify/require"
	"os"
	"regexp"
	"testing"
)

// Verifies that the ACR instance deployed is properly isolated within the VNET
func verifyVnetIntegrationForACR(goTest *testing.T, output infratests.TerraformOutput) {
	appDevResourceGroup := output["app_dev_resource_group"].(string)
	acrName := output["acr_name"].(string)
	acrACLs := azure.ACRNetworkAcls(goTest, adminSubscription, appDevResourceGroup, acrName)
	subnetIDs := azure.VnetSubnetsList(goTest, adminSubscription, aseResourceGroup, os.Getenv("TF_VAR_ase_vnet_name"))

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

// Returns the webhook name used to deploy to a webapp
func getWebhookNameForWebApp(output infratests.TerraformOutput, webAppName string) string {
	return regexp.MustCompile("[-]").ReplaceAllString(webAppName+"cdwebhook", "")
}

// Verifies that the CD webhooks are configured for image PUSH events
func verifyCDHooksConfiguredProperly(goTest *testing.T, output infratests.TerraformOutput) {
	appDevResourceGroup := output["app_dev_resource_group"].(string)
	acrName := output["acr_name"].(string)

	for _, appName := range output["webapp_names"].([]interface{}) {
		appNameS := appName.(string)
		acrWebHook := azure.ACRWebHook(
			goTest,
			adminSubscription,
			appDevResourceGroup,
			acrName,
			getWebhookNameForWebApp(output, appNameS))

		require.Equal(goTest, containerregistry.WebhookStatusEnabled, acrWebHook.Status)
		require.Equal(goTest, 1, len(*acrWebHook.Actions))
		require.Equal(goTest, containerregistry.WebhookAction("push"), (*acrWebHook.Actions)[0])
	}
}
