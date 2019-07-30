package integration

import (
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/microsoft/cobalt/test-harness/infratests"
	"github.com/microsoft/cobalt/test-harness/terratest-extensions/modules/azure"
	"os"
	"testing"
)

var region = "eastus2"

// see note about static workspace in test case below
var workspace = "cobalt-isolated-testing"

var adminSubscription = os.Getenv("TF_VAR_ase_subscription_id")
var aseName = os.Getenv("TF_VAR_ase_name")
var prefix = "isolated-service"
var aseResourceGroup = os.Getenv("TF_VAR_ase_resource_group")

var deploymentTargets = []map[string]string{
	map[string]string{
		"app_name":                 "cobalt-backend-api-1",
		"repository":               "https://github.com/erikschlegel/echo-server.git",
		"dockerfile":               "Dockerfile",
		"image_name":               "appsvcsample/echo-server-1",
		"image_release_tag_prefix": "release",
		"auth_client_id":           "",
	}, map[string]string{
		"app_name":                 "cobalt-backend-api-2",
		"repository":               "https://github.com/erikschlegel/echo-server.git",
		"dockerfile":               "Dockerfile",
		"image_name":               "appsvcsample/echo-server-2",
		"image_release_tag_prefix": "release",
		"auth_client_id":           "",
	},
}

var tfOptions = &terraform.Options{
	TerraformDir: "../../",
	Upgrade:      true,
	Vars: map[string]interface{}{
		"resource_group_location": region,
		"ase_subscription_id":     adminSubscription,
		"ase_name":                aseName,
		"name": 				   prefix,
		"ase_resource_group":      aseResourceGroup,
		"deployment_targets":      deploymentTargets,
	},
	BackendConfig: map[string]interface{}{
		"storage_account_name": os.Getenv("TF_VAR_remote_state_account"),
		"container_name":       os.Getenv("TF_VAR_remote_state_container"),
	},
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
		ExpectedTfOutputCount: 9,
		ExpectedTfOutput: infratests.TerraformOutput{
			"fqdns": []string{
				"http://cobalt-backend-api-1-" + workspace + "." + aseName + ".p.azurewebsites.net",
				"http://cobalt-backend-api-2-" + workspace + "." + aseName + ".p.azurewebsites.net",
			},
			"keyvault_name": "isolated-service-cob-kv",
		},
		TfOutputAssertions: []infratests.TerraformOutputValidation{
			verifyVnetIntegrationForKeyVault,
			verifyVnetIntegrationForACR,
			verifyCDHooksConfiguredProperly,
			verifyCorrectWebhookEndpointForApps,
			verifyCorrectDeploymentTargetForApps,
		},
	}

	azure.CliServicePrincipalLogin(t)
	infratests.RunIntegrationTests(&testFixture)
}
