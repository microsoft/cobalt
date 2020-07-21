package azure

import (
	"context"
	"testing"

	"github.com/Azure/azure-sdk-for-go/services/datafactory/mgmt/2018-06-01/datafactory"
)

func dataFactoryClientE(subscriptionID string) (*datafactory.FactoriesClient, error) {
	authorizer, err := DeploymentServicePrincipalAuthorizer()
	if err != nil {
		return nil, err
	}

	client := datafactory.NewFactoriesClient(subscriptionID)
	client.Authorizer = authorizer
	return &client, nil
}

func pipelineClientE(subscriptionID string) (*datafactory.PipelinesClient, error) {
	authorizer, err := DeploymentServicePrincipalAuthorizer()
	if err != nil {
		return nil, err
	}

	pClient := datafactory.NewPipelinesClient(subscriptionID)
	pClient.Authorizer = authorizer
	return &pClient, nil
}

func datasetClientE(subscriptionID string) (*datafactory.DatasetsClient, error) {
	authorizer, err := DeploymentServicePrincipalAuthorizer()
	if err != nil {
		return nil, err
	}

	dsClient := datafactory.NewDatasetsClient(subscriptionID)
	dsClient.Authorizer = authorizer
	return &dsClient, nil
}

func linkedServiceClientE(subscriptionID string) (*datafactory.LinkedServicesClient, error) {
	authorizer, err := DeploymentServicePrincipalAuthorizer()
	if err != nil {
		return nil, err
	}

	lsClient := datafactory.NewLinkedServicesClient(subscriptionID)
	lsClient.Authorizer = authorizer
	return &lsClient, nil
}

func triggersClientE(subscriptionID string) (*datafactory.TriggersClient, error) {
	authorizer, err := DeploymentServicePrincipalAuthorizer()
	if err != nil {
		return nil, err
	}

	tClient := datafactory.NewTriggersClient(subscriptionID)
	tClient.Authorizer = authorizer
	return &tClient, nil
}

// GetDataFactoryNameByResourceGroup -
func GetDataFactoryNameByResourceGroup(t *testing.T, subscriptionID, resourceGroupName string) string {
	dfList, err := listDataFactoryByResourceGroupE(subscriptionID, resourceGroupName)
	if err != nil {
		t.Fatal(err)
	}

	result := ""
	for _, datafactory := range *dfList {
		result = *datafactory.Name
		break
	}
	return result
}

func listDataFactoryByResourceGroupE(subscriptionID, resourceGroupName string) (*[]datafactory.Factory, error) {
	dfClient, err := dataFactoryClientE(subscriptionID)

	if err != nil {
		return nil, err
	}

	iteratorDataFactory, err := dfClient.ListByResourceGroupComplete(context.Background(), resourceGroupName)
	if err != nil {
		return nil, err
	}

	dataFactoryList := make([]datafactory.Factory, 0)

	for iteratorDataFactory.NotDone() {
		dataFactoryList = append(dataFactoryList, iteratorDataFactory.Value())
		err = iteratorDataFactory.Next()
		if err != nil {
			return nil, err
		}
	}
	return &dataFactoryList, err
}

// ListPipelinesByDataFactory - list names of all pipelines in the given data factory
func ListPipelinesByDataFactory(t *testing.T, subscriptionID string, resourceGroupName string, dataFactoryName string) *[]datafactory.PipelineResource {
	pResults, err := listPipelinesByDataFactoryE(subscriptionID, resourceGroupName, dataFactoryName)

	if err != nil {
		t.Fatal(err)
	}

	return pResults
}

// GetPipeLineNameByDataFactory -
func GetPipeLineNameByDataFactory(t *testing.T, subscriptionID string, resourceGroupName string, dataFactoryName string) string {
	pipelinesList := ListPipelinesByDataFactory(t, subscriptionID, resourceGroupName, dataFactoryName)

	result := ""
	for _, pipeline := range *pipelinesList {
		result = *pipeline.Name
		break
	}
	return result
}

func listPipelinesByDataFactoryE(subscriptionID string, resourceGroupName string, dataFactoryName string) (*[]datafactory.PipelineResource, error) {
	pClient, err := pipelineClientE(subscriptionID)
	if err != nil {
		return nil, err
	}

	iteratorPipelines, err := pClient.ListByFactoryComplete(context.Background(), resourceGroupName, dataFactoryName)
	if err != nil {
		return nil, err
	}

	pipelinesList := make([]datafactory.PipelineResource, 0)

	for iteratorPipelines.NotDone() {
		pipelinesList = append(pipelinesList, iteratorPipelines.Value())
		err = iteratorPipelines.Next()
		if err != nil {
			return nil, err
		}
	}

	return &pipelinesList, err
}

// ListDatasetIDByDataFactory -
func ListDatasetIDByDataFactory(t *testing.T, subscriptionID string, resourceGroupName string, dataFactoryName string) *[]string {
	dsList, err := listDatasetIDByDataFactoryE(subscriptionID, resourceGroupName, dataFactoryName)
	if err != nil {
		t.Fatal(err)
	}

	return dsList
}

func listDatasetIDByDataFactoryE(subscriptionID string, resourceGroupName string, dataFactoryName string) (*[]string, error) {
	dsList, err := listDatasetByDataFactory(subscriptionID, resourceGroupName, dataFactoryName)
	if err != nil {
		return nil, err
	}

	results := make([]string, 0)
	for _, dataset := range *dsList {
		results = append(results, *dataset.ID)
		if err != nil {
			return nil, err
		}
	}

	return &results, nil
}

func listDatasetByDataFactory(subscriptionID string, resourceGroupName string, dataFactoryName string) (*[]datafactory.DatasetResource, error) {

	dsClient, err := datasetClientE(subscriptionID)
	if err != nil {
		return nil, err
	}

	iteratorDataset, err := dsClient.ListByFactoryComplete(context.Background(), resourceGroupName, dataFactoryName)
	if err != nil {
		return nil, err
	}

	dsList := make([]datafactory.DatasetResource, 0)

	for iteratorDataset.NotDone() {
		dsList = append(dsList, iteratorDataset.Value())
		err = iteratorDataset.Next()
		if err != nil {
			return nil, err
		}
	}

	return &dsList, err
}

// ListLinkedServicesIDByDataFactory -
func ListLinkedServicesIDByDataFactory(t *testing.T, subscriptionID string, resourceGroupName string, dataFactoryName string) *[]string {
	lsList, err := listLinkedServicesIDByDataFactoryE(subscriptionID, resourceGroupName, dataFactoryName)
	if err != nil {
		t.Fatal(err)
	}

	return lsList
}

func listLinkedServicesIDByDataFactoryE(subscriptionID string, resourceGroupName string, dataFactoryName string) (*[]string, error) {
	lsList, err := listLinkedServiceByDataFactory(subscriptionID, resourceGroupName, dataFactoryName)
	if err != nil {
		return nil, err
	}

	results := make([]string, 0)
	for _, linkedService := range *lsList {
		results = append(results, *linkedService.ID)
		if err != nil {
			return nil, err
		}
	}

	return &results, nil
}

func listLinkedServiceByDataFactory(subscriptionID string, resourceGroupName string, dataFactoryName string) (*[]datafactory.LinkedServiceResource, error) {

	lsClient, err := linkedServiceClientE(subscriptionID)
	if err != nil {
		return nil, err
	}

	iteratorLinkedService, err := lsClient.ListByFactoryComplete(context.Background(), resourceGroupName, dataFactoryName)
	if err != nil {
		return nil, err
	}

	lsList := make([]datafactory.LinkedServiceResource, 0)

	for iteratorLinkedService.NotDone() {
		lsList = append(lsList, iteratorLinkedService.Value())
		err = iteratorLinkedService.Next()
		if err != nil {
			return nil, err
		}
	}

	return &lsList, err
}
