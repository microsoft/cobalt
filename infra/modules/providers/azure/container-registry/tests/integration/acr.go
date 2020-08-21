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

package integration

import (
	"testing"

	"github.com/microsoft/cobalt/test-harness/infratests"
	"github.com/microsoft/cobalt/test-harness/terratest-extensions/modules/azure"
	"github.com/stretchr/testify/require"
)

// healthCheck - Asserts that the deployment was successful.
func healthCheck(t *testing.T, provisionState string) {
	require.Equal(t, "Succeeded", provisionState, "The deployment hasn't succeeded.")
}

// validateDeployment - Asserts that ACR deployment was successful
func validateDeployment(
	t *testing.T,
	output infratests.TerraformOutput,
	subscription_id string,
	resource_group_name_output string,
	container_registry_name_output string) {

	// Obtain the container registry output name
	acr_name := output[container_registry_name_output].(string)

	// Obtain the registry structure
	resource_group_name := output[resource_group_name_output].(string)

	require.NotEmpty(t, resource_group_name, "Resource Group Name not returned.")
	require.NotEmpty(t, acr_name, "Registry Name not returned.")

	// Get Registry
	registry, err := azure.ACRRegistryE(subscription_id, resource_group_name, acr_name)

	if err != nil {
		t.Fatal(err)
	}

	// Get registry's properties
	properties := registry.RegistryProperties
	// check that the registry was provisioned
	healthCheck(t, string(properties.ProvisioningState))

	// check if the admin settings were disabled
	isAdminEnabled := properties.AdminUserEnabled
	require.Equal(t, false, *isAdminEnabled, "The admin user identity must be disabled for this registry.")

}

// InspectContainerRegistryOutputs - Runs test assertions to validate that the module outputs are valid.
func InspectContainerRegistryOutputs(subscription_id string,
	resource_group_name_output string,
	container_registry_name_output string) func(t *testing.T, output infratests.TerraformOutput) {
	return func(t *testing.T, output infratests.TerraformOutput) {
		validateDeployment(t, output, subscription_id,
			resource_group_name_output,
			container_registry_name_output)
	}
}
