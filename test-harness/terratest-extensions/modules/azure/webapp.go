package azure

import (
	"context"
	"fmt"
	"testing"

	"github.com/Azure/azure-sdk-for-go/services/web/mgmt/2018-02-01/web"
)

func webAppClient(subscriptionID string) (*web.AppsClient, error) {
	authorizer, err := DeploymentServicePrincipalAuthorizer()
	if err != nil {
		return nil, err
	}

	client := web.NewAppsClient(subscriptionID)
	client.Authorizer = authorizer
	return &client, nil
}

// WebAppCDUriE - Return the CD URL that can be used to trigger an ACR pull and redeploy
func WebAppCDUriE(subscriptionID string, resourceGroupName string, webAppName string) (string, error) {

	client, err := webAppClient(subscriptionID)
	if err != nil {
		return "", err
	}

	ctx := context.Background()
	httpResponse, err := client.ListPublishingCredentials(ctx, resourceGroupName, webAppName)
	if err != nil {
		return "", err
	}

	user, err := httpResponse.Result(*client)
	if err != nil {
		return "", err
	}

	scmURI := user.UserProperties.ScmURI
	if scmURI == nil || *scmURI == "" {
		return "", fmt.Errorf("`ScmURI` attribute missing from response of ListPublishingCredentials()")
	}

	return *scmURI + "/docker/hook", nil
}

// WebAppCDUri - Like WebAppCDUriE but fails in the case an error is returned
func WebAppCDUri(t *testing.T, subscriptionID string, resourceGroupName string, webAppName string) string {
	cdURI, err := WebAppCDUriE(subscriptionID, resourceGroupName, webAppName)
	if err != nil {
		t.Fatal(err)
	}
	return cdURI
}

// WebAppSiteConfigurationE - Return the configuration for a webapp
func WebAppSiteConfigurationE(subscriptionID string, resourceGroupName string, webAppName string) (*web.SiteConfig, error) {

	client, err := webAppClient(subscriptionID)
	if err != nil {
		return nil, err
	}

	appConfiguration, err := client.GetConfiguration(context.Background(), resourceGroupName, webAppName)
	if err != nil {
		return nil, err
	}

	return appConfiguration.SiteConfig, nil
}

// WebAppSiteConfiguration - Like WebAppSiteConfigurationE but fails in the case an error is returned
func WebAppSiteConfiguration(t *testing.T, subscriptionID string, resourceGroupName string, webAppName string) *web.SiteConfig {
	appConfiguration, err := WebAppSiteConfigurationE(subscriptionID, resourceGroupName, webAppName)
	if err != nil {
		t.Fatal(err)
	}
	return appConfiguration
}

// GetAllAppList - Get all the App Names from Azure but fails in the case an error is returned
func GetAllAppList(t *testing.T, subscriptionID string) *[]string {
	appNameList, err := getAllAppSiteName(subscriptionID)
	if err != nil {
		t.Fatal(err)
	}
	return appNameList
}

func getAllAppSiteName(subscriptionID string) (*[]string, error) {
	lsList, err := getAppCollections(subscriptionID)
	if err != nil {
		return nil, err
	}

	results := make([]string, 0)
	for _, linkedSite := range *lsList {
		results = append(results, *linkedSite.Name)
		if err != nil {
			return nil, err
		}
	}
	return &results, nil
}

func getAppCollections(subscriptionID string) (*[]web.Site, error) {
	waClient, err := webAppClient(subscriptionID)

	if err != nil {
		return nil, err
	}
	feIterator, err := waClient.ListComplete(context.Background())
	if err != nil {
		return nil, err
	}

	appList := make([]web.Site, 0)

	for feIterator.NotDone() {
		appList = append(appList, feIterator.Value())
		err = feIterator.Next()
		if err != nil {
			return nil, err
		}
	}
	return &appList, err
}
