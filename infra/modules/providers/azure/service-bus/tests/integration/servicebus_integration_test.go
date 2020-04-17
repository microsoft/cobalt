package integraton

import (
	"os"
	"testing"

	"github.com/microsoft/cobalt/infra/modules/providers/azure/service-bus/tests"
	"github.com/microsoft/cobalt/test-harness/infratests"
)

var subscription = os.Getenv("ARM_SUBSCRIPTION_ID")

func TestServiceBus(t *testing.T) {
	testFixture := infratests.IntegrationTestFixture{
		GoTest:                t,
		TfOptions:             tests.ServicebusTFOptions,
		ExpectedTfOutputCount: 7,
		TfOutputAssertions: []infratests.TerraformOutputValidation{
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
	infratests.RunIntegrationTests(&testFixture)
}
