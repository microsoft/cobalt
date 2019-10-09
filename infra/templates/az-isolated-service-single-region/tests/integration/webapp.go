package integration

import (
	"fmt"
	"github.com/microsoft/cobalt/test-harness/infratests"
	"github.com/microsoft/cobalt/test-harness/terratest-extensions/modules/azure"
	"github.com/stretchr/testify/require"
	"strings"
	"testing"
)

// Verifies that the webapp is configured to deploy the correct image. Without this validation we cannot
// be sure that the CD webhook that will trigger the deployment is going to properly target the
// correct webapp.
func verifyCorrectDeploymentTargetForApps(goTest *testing.T, output infratests.TerraformOutput) {
	adminResourceGroup := output["admin_resource_group"].(string)

	for appIndex, appName := range output["webapp_names"].([]interface{}) {
		appConfig := azure.WebAppSiteConfiguration(goTest, adminSubscription, adminResourceGroup, appName.(string))
		linuxFxVersion := strings.Trim(*appConfig.LinuxFxVersion, "{}")
		fmt.Println("Verifying webapp #", appIndex)
		expectedLinuxFxVersion := "DOCKER"
		require.Equal(goTest, expectedLinuxFxVersion, linuxFxVersion)
	}
}
