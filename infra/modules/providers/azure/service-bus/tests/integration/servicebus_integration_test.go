//  Copyright © Microsoft Corporation
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

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
