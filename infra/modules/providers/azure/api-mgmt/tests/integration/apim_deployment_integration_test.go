package test

import (
	"crypto/tls"
	"testing"
	"time"

	httpClient "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/microsoft/cobalt/test-harness/infratests"
)

var tfOptions = &terraform.Options{
	TerraformDir: "../../",
	Upgrade:      true,
	Vars:         map[string]interface{}{},
}

// Validates that the service responds with HTTP 200 status code. A retry strategy
// is used because it may take some time for the application to finish standing up.
func httpGetRespondsWith200(goTest *testing.T, output infratests.TerraformOutput) {
	hostname := output["apim_gateway_url"].(string) + "/petstore/v1/pet/0"
	maxRetries := 20
	timeBetweenRetries := 2 * time.Second
	tlsConfig := tls.Config{}

	err := httpClient.HttpGetWithRetryWithCustomValidationE(
		goTest,
		hostname,
		&tlsConfig,
		maxRetries,
		timeBetweenRetries,
		func(status int, content string) bool {
			return status == 200
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
		ExpectedTfOutputCount: 13,
		TfOutputAssertions: []infratests.TerraformOutputValidation{
			httpGetRespondsWith200,
		},
	}
	infratests.RunIntegrationTests(&testFixture)
}
