package integration

import (
	"fmt"
	"strings"
	"testing"

	"github.com/microsoft/cobalt/test-harness/terratest-extensions/modules/azure"
	"github.com/microsoft/terratest-abstraction/integration"
	"github.com/stretchr/testify/require"
)

// Verifies that the webhook configured in ACR is configured to use the Webhook URI exported
// by the webapp. If this criteria is not met, the webhook in the ACR won't target the
// webapp effectively.
func verifyCorrectWebhookEndpointForApps(goTest *testing.T, output integration.TerraformOutput) {
	acrName := output["acr_name"].(string)
	appDevResourceGroup := output["app_dev_resource_group"].(string)
	adminResourceGroup := output["admin_resource_group"].(string)

	for _, appName := range output["webapp_names"].([]interface{}) {
		appNameS := appName.(string)
		acrWebHook := azure.ACRWebHookCallback(
			goTest,
			adminSubscription,
			appDevResourceGroup,
			acrName,
			getWebhookNameForWebApp(output, appNameS))

		cdURI := azure.WebAppCDUri(goTest, adminSubscription, adminResourceGroup, appNameS)
		require.Equal(goTest, cdURI, *acrWebHook.ServiceURI)
	}
}

// Verifies that the webapp is configured to deploy the correct image. Without this validation we cannot
// be sure that the CD webhook that will trigger the deployment is going to properly target the
// correct webapp.
func verifyCorrectDeploymentTargetForApps(goTest *testing.T, output integration.TerraformOutput) {
	adminResourceGroup := output["admin_resource_group"].(string)

	for appIndex, appName := range output["webapp_names"].([]interface{}) {
		appConfig := azure.WebAppSiteConfiguration(goTest, adminSubscription, adminResourceGroup, appName.(string))
		linuxFxVersion := strings.Trim(*appConfig.LinuxFxVersion, "{}")
		fmt.Println("Verifying webapp #", appIndex)
		expectedLinuxFxVersion := "DOCKER"
		require.Equal(goTest, expectedLinuxFxVersion, linuxFxVersion)
	}
}
