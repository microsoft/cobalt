package test

import (
	"os"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	cosmosdbIntegTests "github.com/microsoft/cobalt/infra/modules/providers/azure/cosmosdb/tests/integration"
	datafactIntegTests "github.com/microsoft/cobalt/infra/modules/providers/azure/data-factory/tests/integration"
	funcAppIntegTests "github.com/microsoft/cobalt/infra/modules/providers/azure/function-app/tests/integration"
	mlWorkspaceTests "github.com/microsoft/cobalt/infra/modules/providers/azure/ml-workspace/tests/integration"
	storageIntegTests "github.com/microsoft/cobalt/infra/modules/providers/azure/storage-account/tests/integration"
	"github.com/microsoft/terratest-abstraction/integration"
)

// SubscriptionID -
var SubscriptionID = os.Getenv("ARM_SUBSCRIPTION_ID")

var tfOptions = &terraform.Options{
	TerraformDir: "../../",
	BackendConfig: map[string]interface{}{
		"storage_account_name": os.Getenv("TF_VAR_remote_state_account"),
		"container_name":       os.Getenv("TF_VAR_remote_state_container"),
	},
}

// Runs a suite of test assertions to validate that a provisioned set of app services
// are fully funtional.
func TestAppSvcPlanSingleRegion(t *testing.T) {
	testFixture := integration.IntegrationTestFixture{
		GoTest:                t,
		TfOptions:             tfOptions,
		ExpectedTfOutputCount: 21,
		TfOutputAssertions: []integration.TerraformOutputValidation{
			//verifyAppServiceConfig,
			/* Now that we configured the services to run as Java containers via linux_fx_version,
			we'll have to temporarily comment out the call to verifyAppServiceEndpointStatusCode...
			The service(s) will be unresponsive until our Azure Pipeline deploys a jar
			to the target app service. We'll remove the comment once our service CI/CD pipelines are in place.
			verifyAppServiceEndpointStatusCode,
			*/
			storageIntegTests.InspectStorageAccount("sys_storage_account", "sys_storage_account_containers", "app_dev_resource_group"),
			storageIntegTests.InspectStorageAccount("app_storage_account_name", "app_storage_account_containers", "app_dev_resource_group"),
			mlWorkspaceTests.VerifyCreatedMLworkspace(SubscriptionID, "mlw_dev_resource_group", "mlw_id"),
			datafactIntegTests.VerifyCreatedDataFactory(SubscriptionID, "app_dev_resource_group", "data_factory_name"),
			funcAppIntegTests.VerifyCreatedFunctionApp(SubscriptionID, "azure_functionapp_name"),
			cosmosdbIntegTests.VerifyProvisionedCosmosDBAccount(SubscriptionID, "cosmosdb_resource_group_name", "cosmosdb_account_name"),
		},
	}
	integration.RunIntegrationTests(&testFixture)
}
