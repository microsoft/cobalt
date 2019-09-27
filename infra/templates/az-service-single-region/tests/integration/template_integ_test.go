package test

import (
	"crypto/tls"
	"crypto/x509"
	"fmt"
	"net/http"
	"os"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/microsoft/cobalt/test-harness/infratests"
	"github.com/microsoft/cobalt/test-harness/terratest-extensions/modules/azure"
)

var tfOptions = &terraform.Options{
	TerraformDir: "../../",
	Upgrade:      true,
	BackendConfig: map[string]interface{}{
		"storage_account_name": os.Getenv("TF_VAR_remote_state_account"),
		"container_name":       os.Getenv("TF_VAR_remote_state_container"),
	},
}

// Validates that the front-end endpoint is available via HTTPS using SSL
func verifyHTTPSSuccessOnFrontEnd(goTest *testing.T, output infratests.TerraformOutput) {
	frontEndHost := output["tm_fqdn"].(string)
	httpClient := configureHTTPSClient(output)

	response, err := httpClient.Get("https://" + frontEndHost)
	if err != nil {
		goTest.Fatal(err)
	}

	if response.StatusCode != 200 {
		goTest.Fatal(fmt.Errorf("expected status 200 but got %d", response.StatusCode))
	}
}

// Validates that the front-end endpoint is not available via HTTP
func verifyHTTPFailsOnFrontEnd(goTest *testing.T, output infratests.TerraformOutput) {
	frontEndHost := output["tm_fqdn"].(string)
	verifyRequestFails(goTest, frontEndHost, "https", &http.Client{})
}

// Validates that the back-end endpoint is not available via HTTPS
func verifyHTTPSFailsOnBackEnd(goTest *testing.T, output infratests.TerraformOutput) {
	backEndHost := output["app_gateway_health_probe_backend_address"].(string)
	verifyRequestFails(goTest, backEndHost, "https", configureHTTPSClient(output))
}

// Validates that the back-end endpoint is not available via HTTP
func verifyHTTPFailsOnBackEnd(goTest *testing.T, output infratests.TerraformOutput) {
	backEndHost := output["app_gateway_health_probe_backend_address"].(string)
	verifyRequestFails(goTest, backEndHost, "http", &http.Client{})
}

// Configures an HTTPS client for the web app
func configureHTTPSClient(output infratests.TerraformOutput) *http.Client {
	cert := output["public_cert"].(string)
	backEndHost := output["app_gateway_health_probe_backend_address"].(string)

	certPool := x509.NewCertPool()
	certPool.AppendCertsFromPEM([]byte("-----BEGIN CERTIFICATE-----\n" + cert + "\n-----END CERTIFICATE-----"))

	return &http.Client{
		Transport: &http.Transport{
			TLSClientConfig: &tls.Config{
				RootCAs:    certPool,
				ServerName: backEndHost,
			},
		},
	}
}

// Validates that a request fails
func verifyRequestFails(goTest *testing.T, host string, protocol string, client *http.Client) {
	response, err := client.Get(protocol + "://" + host)
	if err != nil || response.StatusCode != 200 {
		return
	}

	goTest.Fatal(fmt.Errorf("expected HTTP request to fail but got status code %d", response.StatusCode))
}

func TestAzureSimple(t *testing.T) {
	azure.CliServicePrincipalLogin(t)

	testFixture := infratests.IntegrationTestFixture{
		GoTest:                t,
		TfOptions:             tfOptions,
		ExpectedTfOutputCount: 5,
		ExpectedTfOutput: infratests.TerraformOutput{
			"app_gateway_health_probe_backend_status": "Healthy",
		},
		TfOutputAssertions: []infratests.TerraformOutputValidation{
			verifyHTTPSSuccessOnFrontEnd,
			verifyHTTPFailsOnFrontEnd,
			verifyHTTPSFailsOnBackEnd,
			verifyHTTPFailsOnBackEnd,
		},
	}
	infratests.RunIntegrationTests(&testFixture)
}
