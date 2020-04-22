package integration

import (
	"fmt"
	"math/rand"
	"os"
	"strconv"
	"testing"
	"time"

	"github.com/microsoft/cobalt/test-harness/infratests"
	"github.com/microsoft/cobalt/test-harness/terratest-extensions/modules/azure"
	"github.com/stretchr/testify/require"
)

var subscription = os.Getenv("ARM_SUBSCRIPTION_ID")

// redisHealthCheck - Asserts that the deployment was succesful.
func redisHealthCheck(t *testing.T, provionState string) {
	require.Equal(t, string(provionState), "Succeeded", "The redis deployment hasn't succeeded")
}

// validateNonSSLPort - Asserts that non SSL ports are disabled
func validateNonSSLPort(t *testing.T, NonSSLPort *bool) {
	require.False(t, *NonSSLPort, "There's a non SSL port opened on the redis cluster")
}

// validateMinTLSVersion - Validate that the min TLS version isn't nil and >= 1.0
func validateMinTLSVersion(t *testing.T, minTLSVersion string) {
	minTLSVersionFloat, err := strconv.ParseFloat(minTLSVersion, 32)
	if err != nil {
		t.Fatal(err)
	}

	require.True(t, minTLSVersionFloat >= 1, "Min TLS version should be >= 1.0")
}

// validateResourceGroupCaches - Validate the caches within the resource group
func validateResourceGroupCacheCount(t *testing.T, caches []string, expectedCacheName string) {
	expectedResourceGroupCaches := []string{expectedCacheName}

	require.Equal(t, expectedResourceGroupCaches, caches, "The provisioned caches in the RG don't match the expected result")
}

// InspectProvisionedCache - Runs a suite of test assertions to validate that a provisioned redis cache
// is operational.
func InspectProvisionedCache(cacheOutputName string, resourceGroupOutputName string) func(t *testing.T, output infratests.TerraformOutput) {
	return func(t *testing.T, output infratests.TerraformOutput) {
		cacheName := output[cacheOutputName].(string)
		resourceGroup := output[resourceGroupOutputName].(string)
		results := azure.GetCache(t, subscription, resourceGroup, cacheName)
		cacheNameList := []string{}

		for _, resourceType := range *azure.ListCachesByResourceGroup(t, subscription, resourceGroup) {
			cacheNameList = append(cacheNameList, string(*resourceType.Name))
		}

		validateResourceGroupCacheCount(t, cacheNameList, cacheName)
		redisHealthCheck(t, string(results.ProvisioningState))
		validateNonSSLPort(t, results.EnableNonSslPort)
		validateMinTLSVersion(t, string(results.MinimumTLSVersion))
	}
}

// CheckRedisWriteOperations - Runs a suite of test assertions to validate that entries can be written and read from an redis cluster
func CheckRedisWriteOperations(hostnameOutputName string, primaryKeyOutputName string, hostPortOutputName string) func(t *testing.T, output infratests.TerraformOutput) {
	return func(t *testing.T, output infratests.TerraformOutput) {
		primaryKey := output[primaryKeyOutputName].(string)
		hostname := output[hostnameOutputName].(string)
		hostPort := output[hostPortOutputName].(float64)
		address := fmt.Sprintf("%s:%d", hostname, int(hostPort))
		rand.Seed(time.Now().UnixNano())
		entryIdentifier := rand.Int()
		keyName := fmt.Sprintf("key-%d", entryIdentifier)
		client := azure.RedisClient(t, address, primaryKey)
		keyValue := "entryTestValue"

		require.Equal(t, azure.SetRedisCacheEntry(t, client, keyName, keyValue, 0), "OK", "Redis cache key set operation result doesn't match the expected result")
		require.Equal(t, azure.GetRedisCacheEntryValueStr(t, client, keyName), keyValue, "Redis cache key get operation result doesn't match the expected result")
		require.Equal(t, azure.RemoveRedisCacheEntry(t, client, keyName), int64(1), "Redis cache key removal operation result doesn't match the expected result")
	}
}
