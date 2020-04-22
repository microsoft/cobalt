package integraton

import (
	"os"
	"testing"

	"github.com/microsoft/cobalt/infra/modules/providers/azure/service-bus/tests"
	"github.com/microsoft/terratest-abstraction/integration"
)

var subscription = os.Getenv("ARM_SUBSCRIPTION_ID")

func TestServiceBus(t *testing.T) {
	testFixture := integration.IntegrationTestFixture{
		GoTest:                t,
		TfOptions:             tests.ServicebusTFOptions,
		ExpectedTfOutputCount: 7,
		TfOutputAssertions: []integration.TerraformOutputValidation{
			VerifySubscriptionsList(subscription,
				"resource_group",
				"namespace_name",
				"topics",
			),
			verifyTopicAuthenticationRuleList(subscription,
				"resource_group",
				"namespace_name",
				"topics",
			),
			verifyNamespaceAuthenticationRuleList(subscription,
				"resource_group",
				"namespace_name",
				"namespace_authorization_rules",
			),
		},
	}
	integration.RunIntegrationTests(&testFixture)
}
