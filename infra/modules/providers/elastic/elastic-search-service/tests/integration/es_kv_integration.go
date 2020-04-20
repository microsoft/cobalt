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
)

// KvElasticEndpoint the keyvault secret name containing the elastic endpoint
var KvElasticEndpoint = "elastic-endpoint"

// KvElasticUsername the keyvault secret name containing the elastic username
var KvElasticUsername = "elastic-username"

// KvElasticPassword the keyvault secret name containing the elastic password
var KvElasticPassword = "elastic-password"

// getEsExpectedKvSecretMap - Constructs the expected keyvault secret attributes based off the Terraform output
func getEsExpectedKvSecretMap(output infratests.TerraformOutput, esClusterOutputName string) map[string]string {
	expectedSecretAttributes := map[string]string{}
	clusterProperties := output[esClusterOutputName].(map[string]interface{})
	elasticProperties := clusterProperties["elastic_search"].(map[string]interface{})
	endpoint := elasticProperties["endpoint"].(string)
	username := elasticProperties["username"].(string)
	password := elasticProperties["password"].(string)

	expectedSecretAttributes[KvElasticEndpoint] = endpoint
	expectedSecretAttributes[KvElasticUsername] = username
	expectedSecretAttributes[KvElasticPassword] = password

	return expectedSecretAttributes
}

// Constructs all provisioned keyvault secret attributes fetched from Azure
func getEsActualKvSecretMap(t *testing.T, output infratests.TerraformOutput, kvSecretAttributeOutputName string, vaultURIOutputname string) map[string]string {
	actualSecretAttributes := map[string]string{}
	kvSecretProperties := output[kvSecretAttributeOutputName].(map[string]interface{})
	vaultURI := output[vaultURIOutputname].(string)
	esEndpointSecretProperties := kvSecretProperties[KvElasticEndpoint].(map[string]interface{})
	esPasswordSecretProperties := kvSecretProperties[KvElasticPassword].(map[string]interface{})
	esUsernameSecretProperties := kvSecretProperties[KvElasticUsername].(map[string]interface{})

	endpoint := azure.GetKeyVaultSecretValue(t, vaultURI, KvElasticEndpoint, esEndpointSecretProperties["version"].(string))
	username := azure.GetKeyVaultSecretValue(t, vaultURI, KvElasticUsername, esUsernameSecretProperties["version"].(string))
	password := azure.GetKeyVaultSecretValue(t, vaultURI, KvElasticPassword, esPasswordSecretProperties["version"].(string))

	actualSecretAttributes[KvElasticEndpoint] = *endpoint
	actualSecretAttributes[KvElasticUsername] = *username
	actualSecretAttributes[KvElasticPassword] = *password

	return actualSecretAttributes
}
