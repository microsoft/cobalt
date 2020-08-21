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
