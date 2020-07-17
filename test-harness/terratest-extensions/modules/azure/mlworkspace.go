package azure

import (
	"context"
	"testing"

	"github.com/Azure/azure-sdk-for-go/services/machinelearningservices/mgmt/2020-01-01/machinelearningservices"
)

func mlWorkSpaceClientE(subscriptionID string) (*machinelearningservices.WorkspacesClient, error) {
	authorizer, err := DeploymentServicePrincipalAuthorizer()
	if err != nil {
		return nil, err
	}
	client := machinelearningservices.NewWorkspacesClient(subscriptionID)
	client.Authorizer = authorizer
	return &client, err
}

// GetMLWorkspaceIDByResourceGroup -
func GetMLWorkspaceIDByResourceGroup(t *testing.T, subscriptionID, resourceGroupName string) string {
	dfList, err := listMlWorkspaceByResourceGroupE(subscriptionID, resourceGroupName)
	if err != nil {
		t.Fatal(err)
	}

	result := ""
	for _, workspace := range *dfList {
		result = *workspace.ID
		break
	}
	return result
}

func listMlWorkspaceByResourceGroupE(subscriptionID, resourceGroupName string) (*[]machinelearningservices.Workspace, error) {
	dfClient, err := mlWorkSpaceClientE(subscriptionID)

	if err != nil {
		return nil, err
	}
	iteratorMlWorkspace, err := dfClient.ListByResourceGroupComplete(context.Background(), resourceGroupName, "")
	if err != nil {
		return nil, err
	}
	mlWorkspaceList := make([]machinelearningservices.Workspace, 0)
	for iteratorMlWorkspace.NotDone() {
		mlWorkspaceList = append(mlWorkspaceList, iteratorMlWorkspace.Value())
		err = iteratorMlWorkspace.Next()
		if err != nil {
			return nil, err
		}
	}
	return &mlWorkspaceList, err
}
