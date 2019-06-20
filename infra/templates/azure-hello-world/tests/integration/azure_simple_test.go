package test

import (
	"fmt"
	"os"
	"strings"
	"testing"
	"time"

	httpClient "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/microsoft/cobalt/test-harness/infratests"
)

var workspace = fmt.Sprintf("azure-hello-world-%s", random.UniqueId())
var prefix = fmt.Sprintf("helloworld-int-tst-%s", random.UniqueId())
var datacenter = os.Getenv("DATACENTER_LOCATION")

var tfOptions = &terraform.Options{
	TerraformDir: "../../",
	Upgrade:      true,
	Vars: map[string]interface{}{
		"prefix":                  prefix,
		"resource_group_location": datacenter,
	},
	BackendConfig: map[string]interface{}{
		"storage_account_name": os.Getenv("TF_VAR_remote_state_account"),
		"container_name":       os.Getenv("TF_VAR_remote_state_container"),
	},
}

// Validates that the service responds with HTTP 200 status code. A retry strategy
// is used because it may take some time for the application to finish standing up.
func httpGetRespondsWith200(goTest *testing.T, output infratests.TerraformOutput) {
	hostname := output["app_service_default_hostname"].(string)
	maxRetries := 20
	timeBetweenRetries := 2 * time.Second
	expectedResponse := "Hello App Service!"

	err := httpClient.HttpGetWithRetryWithCustomValidationE(
		goTest,
		hostname,
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
	testFixture := infratests.IntegrationTestFixture{
		GoTest:                t,
		TfOptions:             tfOptions,
		Workspace:             workspace,
		ExpectedTfOutputCount: 1,
		ExpectedTfOutput: infratests.TerraformOutput{
			"app_service_default_hostname": strings.ToLower(fmt.Sprintf("http://cobalt-backend-api-%s.azurewebsites.net", workspace)),
		},
		TfOutputAssertions: []infratests.TerraformOutputValidation{
			httpGetRespondsWith200,
		},
	}
	infratests.RunIntegrationTests(&testFixture)
}
