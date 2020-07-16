package test

import (
	"crypto/tls"
	"strings"
	"testing"

	httpClient "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/microsoft/cobalt/test-harness/terratest-extensions/modules/azure"
	"github.com/microsoft/terratest-abstraction/integration"
	"github.com/stretchr/testify/require"
)

// Verifies that the provisioned webapp is properly configured.
func verifyAppServiceConfig(goTest *testing.T, output integration.TerraformOutput) {
	resourceGroup := output["app_dev_resource_group"].(string)

	for _, appName := range output["webapp_names"].([]interface{}) {
		appConfig := azure.WebAppSiteConfiguration(goTest, SubscriptionID, resourceGroup, appName.(string))
		linuxFxVersion := strings.Trim(*appConfig.LinuxFxVersion, "{}")
		expectedLinuxFxVersion := ""
		require.Equal(goTest, expectedLinuxFxVersion, linuxFxVersion)
	}
}

// Verifies that the provisioned webapp is properly configured.
func verifyAppServiceEndpointStatusCode(goTest *testing.T, output integration.TerraformOutput) {
	for _, fqdn := range output["app_service_fqdns"].([]interface{}) {
		require.True(goTest, httpGetRespondsWithCode(goTest, fqdn.(string), 401))
	}
}

// Validates that the service responds with provided HTTP Code.
func httpGetRespondsWithCode(goTest *testing.T, url string, code int) bool {

	tlsConfig := tls.Config{}
	statusCode, _, err := httpClient.HttpGetE(goTest, url, &tlsConfig)
	if err != nil {
		goTest.Fatal(err)
	}

	return statusCode == code
}

func arrayContains(arr []interface{}, str string) bool {
	for _, a := range arr {
		if a == str {
			return true
		}
	}
	return false
}
