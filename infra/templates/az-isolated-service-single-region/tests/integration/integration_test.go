package test

import (
	"os"
	"strings"
	"testing"
	"time"

	httpClient "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/microsoft/cobalt/test-harness/infratests"
)

var region = "eastus2"

// see note about static workspace in test case below
var workspace = "cobalt-isolated-testing"

var admin_subscription = os.Getenv("TF_VAR_admin_subscription_id")
var ase_name = os.Getenv("TF_VAR_app_service_environment_name")
var ase_resource_group = os.Getenv("TF_VAR_app_service_environment_resource_group")

var tfOptions = &terraform.Options{
	TerraformDir: "../../",
	Upgrade:      true,
	Vars: map[string]interface{}{
		"resource_group_location": region,
		"ase_subscription_id":     admin_subscription,
		"ase_name":                ase_name,
		"ase_resource_group":      ase_resource_group,
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
		if err != nil {
			goTest.Fatal(err)
		}
	}
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
		ExpectedTfOutputCount: 1,
		ExpectedTfOutput: infratests.TerraformOutput{
			"fqdns": []string{
				"http://cobalt-backend-api-1-" + workspace + "." + ase_name + ".p.azurewebsites.net",
				"http://cobalt-backend-api-2-" + workspace + "." + ase_name + ".p.azurewebsites.net",
			},
		},
		TfOutputAssertions: []infratests.TerraformOutputValidation{
			httpGetRespondsWith200,
		},
	}
	infratests.RunIntegrationTests(&testFixture)
}
