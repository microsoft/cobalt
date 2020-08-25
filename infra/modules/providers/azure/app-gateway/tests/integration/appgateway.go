package integration

import (
	"os"
	"testing"

	"github.com/Azure/azure-sdk-for-go/services/network/mgmt/2019-02-01/network"
	"github.com/microsoft/cobalt/test-harness/terratest-extensions/modules/azure"
	"github.com/microsoft/terratest-abstraction/integration"
	"github.com/stretchr/testify/require"
)

var subscription = os.Getenv("ARM_SUBSCRIPTION_ID")

func checkMinCapactiy(t *testing.T, appGatewayProperties *network.ApplicationGatewayPropertiesFormat) {
	minCapacity := appGatewayProperties.AutoscaleConfiguration.MinCapacity
	require.Equal(t, int32(2), *minCapacity)
}

func checkOWASPRuleset(t *testing.T, appGatewayProperties *network.ApplicationGatewayPropertiesFormat) {
	firewallRulesetType := appGatewayProperties.WebApplicationFirewallConfiguration.RuleSetType
	firewallRulesetVersion := appGatewayProperties.WebApplicationFirewallConfiguration.RuleSetVersion
	require.Equal(t, "OWASP", *firewallRulesetType, "Firewall ruleset type is incorrect")
	require.Equal(t, "3.1", *firewallRulesetVersion, "Firewall ruleset version is incorrect")
}

func checkAvailablePorts(t *testing.T, appGatewayProperties *network.ApplicationGatewayPropertiesFormat) {
	foundPort := false
	frontendPorts := appGatewayProperties.FrontendPorts
	for _, frontend := range *frontendPorts {
		if *frontend.Port == int32(443) {
			foundPort = true
		}
	}
	require.True(t, foundPort, "Failed to find a frontendPort with port 443")
}

func checkSSLCertificates(t *testing.T, appGatewayProperties *network.ApplicationGatewayPropertiesFormat, keyvaultSecretID string) {
	certs := appGatewayProperties.SslCertificates
	require.Equal(t, 1, len(*certs))
	cert := (*certs)[0]
	require.Equal(t, "Succeeded", *cert.ProvisioningState)
	require.Equal(t, keyvaultSecretID, *cert.KeyVaultSecretID)
}

// InspectAppGateway - Runs a suite of test assertions to validate properties for an application gateway
func InspectAppGateway(resourceGroupNameOutput string, appGatewayNameOutput string, keyvaultIDOutput string) func(t *testing.T, output integration.TerraformOutput) {
	return func(t *testing.T, output integration.TerraformOutput) {
		appGatewayName := output[appGatewayNameOutput].(string)
		resourceGroupName := output[resourceGroupNameOutput].(string)
		keyvaultSecretID := output[keyvaultIDOutput].(string)

		appGateway, err := azure.GetAppGatewayProperties(subscription, resourceGroupName, appGatewayName)
		if err != nil {
			t.Fatal(err)
		}

		appGatewayProperties := appGateway.ApplicationGatewayPropertiesFormat

		checkMinCapactiy(t, appGatewayProperties)
		checkOWASPRuleset(t, appGatewayProperties)
		checkSSLCertificates(t, appGatewayProperties, keyvaultSecretID)
	}
}
