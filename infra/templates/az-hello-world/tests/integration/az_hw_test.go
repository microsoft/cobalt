package test

import (
	"os"
	"strings"
	"testing"
	"time"

	httpClient "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/microsoft/terratest-abstraction/integration"
)

var tfOptions = &terraform.Options{
	TerraformDir: "../../",
	Upgrade:      true,
	BackendConfig: map[string]interface{}{
		"storage_account_name": os.Getenv("TF_VAR_remote_state_account"),
		"container_name":       os.Getenv("TF_VAR_remote_state_container"),
	},
}

// Validates that the service responds with HTTP 200 status code. A retry strategy
// is used because it may take some time for the application to finish standing up.
func httpGetRespondsWith200(goTest *testing.T, output integration.TerraformOutput) {
	hostname := output["app_service_default_hostname"].(string)
	maxRetries := 20
	timeBetweenRetries := 2 * time.Second
	expectedResponse := "Hello App Service!"

	err := httpClient.HttpGetWithRetryWithCustomValidationE(
		goTest,
		hostname,
		nil,
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

func TestAzureSimple(t *testing.T) {
	testFixture := integration.IntegrationTestFixture{
		GoTest:                t,
		TfOptions:             tfOptions,
		ExpectedTfOutputCount: 1,
		TfOutputAssertions: []integration.TerraformOutputValidation{
			httpGetRespondsWith200,
		},
	}
	integration.RunIntegrationTests(&testFixture)
}
