package azure

import (
	"context"
	"testing"

	"github.com/Azure/azure-sdk-for-go/services/cosmos-db/mgmt/2015-04-08/documentdb"
)

// cosmosClientE - Connects to the cosmos client
func cosmosClientE(subscriptionID string) (*documentdb.DatabaseAccountsClient, error) {
	authorizer, err := DeploymentServicePrincipalAuthorizer()
	if err != nil {
		return nil, err
	}

	client := documentdb.NewDatabaseAccountsClient(subscriptionID)
	client.Authorizer = authorizer
	// Appends given user agent value to header for all future http calls to cosmos server for duration of integ tests.
	client.AddToUserAgent("integration-test-harness")
	return &client, err
}

func getCosmosDBAccountE(subscriptionID string, resourceGroupName string, accountName string) (*documentdb.DatabaseAccount, error) {
	client, err := cosmosClientE(subscriptionID)

	if err != nil {
		return nil, err
	}

	ctx := context.Background()
	response, err := client.Get(ctx, resourceGroupName, accountName)

	if err != nil {
		return nil, err
	}

	return &response, nil
}

// GetCosmosDBAccount - Retrieves the properties of a CosmosDB Database Account.
func GetCosmosDBAccount(t *testing.T, subscriptionID string, resourceGroupName string, accountName string) *documentdb.DatabaseAccount {
	resource, err := getCosmosDBAccountE(subscriptionID, resourceGroupName, accountName)

	if err != nil {
		t.Fatal(err)
	}

	return resource
}
