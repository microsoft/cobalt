package integration

import (
	"bytes"
	"crypto/tls"
	"encoding/json"
	"fmt"
	"math/rand"
	"net/http"
	"strings"
	"testing"
	"time"

	es6 "github.com/elastic/go-elasticsearch/v6"
	es6api "github.com/elastic/go-elasticsearch/v6/esapi"
	"github.com/microsoft/cobalt/infra/modules/providers/elastic/elastic-cloud-enterprise/tests"
	"github.com/microsoft/cobalt/test-harness/infratests"
	"github.com/stretchr/testify/require"
)

// healthcheck values are described here:
//	https://www.elastic.co/guide/en/elasticsearch/reference/current/cluster-health.html
var expectedESHealthStatus = []string{"green", "yellow"}
var integTestIndexName = "integration_test_index"

// Returns a configured client for Elasticsearch. The configuration is
// based on the output of the terraform module
func getESClientFromOutput(t *testing.T, output infratests.TerraformOutput, esClusterOutputName string) *es6.Client {
	clusterProperties := output[esClusterOutputName].(map[string]interface{})
	elasticProperties := clusterProperties["elastic_search"].(map[string]interface{})
	addresses := []string{elasticProperties["endpoint"].(string)}
	username := elasticProperties["username"].(string)
	password := elasticProperties["password"].(string)

	return getESClient(t, addresses, username, password)
}

// Returns a configured client for Elasticsearch. The configuration is
// based on the cluster credentials
func getESClient(t *testing.T, endpoints []string, username string, password string) *es6.Client {
	client, err := es6.NewClient(es6.Config{
		Addresses: endpoints,
		Username:  username,
		Password:  password,
		Transport: &http.Transport{
			// This is used (for now) because the installation we have to play with
			// does not have SSL certificates properly configured. We should remove
			// this when we move to a production ECE installation.
			TLSClientConfig: &tls.Config{InsecureSkipVerify: true},
		},
	})
	if err != nil {
		t.Fatal(fmt.Errorf("Failed to create Elasticsearch client: %v", err))
	}

	return client
}

// Executes an API call against ES and transforms the response into a JSON-like structure. Error
// handling is done here as well - any error encountered will fail the test.
func invokeESAPI(t *testing.T, action func() (*es6api.Response, error)) map[string]interface{} {
	var r map[string]interface{}
	res, err := action()
	defer res.Body.Close()
	if err != nil {
		t.Fatal(fmt.Errorf("Cannot invoke call to Elasticsearch. Error: %v", err))
	}

	if res.IsError() {
		t.Fatal(fmt.Errorf("Cannot deserialize error response. Response: %s", res.String()))
	}

	if err = json.NewDecoder(res.Body).Decode(&r); err != nil {
		t.Fatal(fmt.Errorf("Cannot parse response body `%v`: %v", res.Body, err))
	}

	return r
}

// CheckClusterHealth return a function that verifies that the cluster health is in an acceptable state
func CheckClusterHealth(esClusterOutputName string) func(t *testing.T, output infratests.TerraformOutput) {
	return func(t *testing.T, output infratests.TerraformOutput) {
		response := invokeESAPI(t, func() (*es6api.Response, error) {
			return getESClientFromOutput(t, output, esClusterOutputName).Cluster.Health()
		})

		actualESStatus := response["status"].(string)
		for _, allowedStatus := range expectedESHealthStatus {
			if strings.EqualFold(allowedStatus, actualESStatus) {
				return
			}
		}

		t.Fatal(fmt.Errorf("Expected Elastic Health Check to return one of `%s` but got `%s`",
			strings.Join(expectedESHealthStatus, ","),
			actualESStatus))
	}
}

// CheckClusterVersion return a function that verifies that the correct version of
// Elasticsearch has been deployed
func CheckClusterVersion(esClusterOutputName string) func(t *testing.T, output infratests.TerraformOutput) {
	return func(t *testing.T, output infratests.TerraformOutput) {
		response := invokeESAPI(t, func() (*es6api.Response, error) {
			return getESClientFromOutput(t, output, esClusterOutputName).Info()
		})

		actualESVersion := response["version"].(map[string]interface{})["number"].(string)
		if !strings.EqualFold(tests.ESVersion, actualESVersion) {
			t.Fatal(fmt.Errorf("Expected ESVersion = `%s` but was `%s`", tests.ESVersion, actualESVersion))
		}
	}
}

// CheckClusterIndexing return a function that verifies that a document can be indexed,
// retrieved, and deleted from an index that is specific to integration testing
func CheckClusterIndexing(esClusterOutputName string) func(t *testing.T, output infratests.TerraformOutput) {
	return func(t *testing.T, output infratests.TerraformOutput) {
		rand.Seed(time.Now().UnixNano())
		documentID := rand.Int()
		document := []byte(fmt.Sprintf("{\"key\": %d}", documentID))
		esClient := getESClientFromOutput(t, output, esClusterOutputName)

		// index a document into the integration test index in Elasticsearch
		invokeESAPI(t, func() (*es6api.Response, error) {
			return esClient.Create(
				integTestIndexName,
				fmt.Sprintf("%d", documentID),
				bytes.NewReader(document))
		})

		// retrieve the document to make sure it was created. This will fail with a 401 if not found
		invokeESAPI(t, func() (*es6api.Response, error) {
			return esClient.Get(
				integTestIndexName,
				fmt.Sprintf("%d", documentID))
		})

		// clean up the indexed document as its not needed anymore
		invokeESAPI(t, func() (*es6api.Response, error) {
			return esClient.Delete(
				integTestIndexName,
				fmt.Sprintf("%d", documentID))
		})
	}
}

// ValidateElasticKvSecretValues - Validates that the correct secrets have been provisioned
func ValidateElasticKvSecretValues(keyvaultSecretOutputName string, elasticClusterPropsOutputName string) func(t *testing.T, output infratests.TerraformOutput) {
	return func(t *testing.T, output infratests.TerraformOutput) {
		actual := getEsActualKvSecretMap(t, output, keyvaultSecretOutputName, "keyvault_uri")
		expected := getEsExpectedKvSecretMap(output, elasticClusterPropsOutputName)
		require.Equal(t, expected, actual, "Incorrect secrets have been created / modified in Azure")
	}
}
