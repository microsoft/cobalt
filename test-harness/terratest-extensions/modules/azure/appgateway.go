package azure

import (
	"context"

	"github.com/Azure/azure-sdk-for-go/services/network/mgmt/2019-02-01/network"
)

func applicationGatewaysClientE(subscriptionID string) (*network.ApplicationGatewaysClient, error) {
	authorizer, err := DeploymentServicePrincipalAuthorizer()
	if err != nil {
		return nil, err
	}

	client := network.NewApplicationGatewaysClient(subscriptionID)
	client.Authorizer = authorizer
	return &client, nil
}

func getAppGatewayPropertiesE(client *network.ApplicationGatewaysClient, resourceGroupName string, applicationGatewayName string) (*network.ApplicationGateway, error) { //?
	ctx := context.Background()

	applicationGateway, err := client.Get(ctx, resourceGroupName, applicationGatewayName)
	if err != nil {
		return nil, err
	}

	return &applicationGateway, nil
}

// GetAppGatewayProperties - Get properties for an app gateway
func GetAppGatewayProperties(subscription string, resourceGroupName string, appGatewayName string) (*network.ApplicationGateway, error) {
	client, err := applicationGatewaysClientE(subscription)
	if err != nil {
		return nil, err
	}

	appGateway, err := getAppGatewayPropertiesE(client, resourceGroupName, appGatewayName)
	if err != nil {
		return nil, err
	}

	return appGateway, nil
}
