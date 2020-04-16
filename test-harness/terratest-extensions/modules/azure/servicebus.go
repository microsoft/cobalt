package azure

import (
	"context"
	"testing"

	"github.com/Azure/azure-sdk-for-go/services/servicebus/mgmt/2017-04-01/servicebus"
)

func serviceBusClientE(subscriptionID string) (*servicebus.BaseClient, error) {
	authorizer, err := DeploymentServicePrincipalAuthorizer()
	if err != nil {
		return nil, err
	}

	client := servicebus.New(subscriptionID)
	client.Authorizer = authorizer
	return &client, nil
}

func serviceBusNamespaceClientE(subscriptionID string) (*servicebus.NamespacesClient, error) {
	authorizer, err := DeploymentServicePrincipalAuthorizer()
	if err != nil {
		return nil, err
	}

	nsClient := servicebus.NewNamespacesClient(subscriptionID)
	nsClient.Authorizer = authorizer
	return &nsClient, nil
}

func serviceBusTopicClientE(subscriptionID string) (*servicebus.TopicsClient, error) {
	authorizer, err := DeploymentServicePrincipalAuthorizer()
	if err != nil {
		return nil, err
	}

	tClient := servicebus.NewTopicsClient(subscriptionID)
	tClient.Authorizer = authorizer
	return &tClient, nil
}

func serviceBusSubscriptionsClientE(subscriptionID string) (*servicebus.SubscriptionsClient, error) {
	authorizer, err := DeploymentServicePrincipalAuthorizer()
	if err != nil {
		return nil, err
	}

	sClient := servicebus.NewSubscriptionsClient(subscriptionID)
	sClient.Authorizer = authorizer
	return &sClient, nil
}

// ListServiceBusNamespaceE list all SB namespaces in all resource groups in the given subscription ID
func ListServiceBusNamespaceE(subscriptionID string) (*[]servicebus.SBNamespace, error) {
	nsClient, err := serviceBusNamespaceClientE(subscriptionID)
	if err != nil {
		return nil, err
	}

	iteratorSBNamespace, err := nsClient.ListComplete(context.Background())
	if err != nil {
		return nil, err
	}

	results := make([]servicebus.SBNamespace, 0)
	for iteratorSBNamespace.NotDone() {
		results = append(results, iteratorSBNamespace.Value())
		err = iteratorSBNamespace.Next()
		if err != nil {
			return nil, err
		}
	}

	return &results, nil
}

// ListServiceBusNamespace - like ListServiceBusNamespaceE but fails in the case an error is returned
func ListServiceBusNamespace(t *testing.T, subscriptionID string) *[]servicebus.SBNamespace {
	results, err := ListServiceBusNamespaceE(subscriptionID)
	if err != nil {
		t.Fatal(err)
	}

	return results
}

// ListServiceBusNamespaceNamesE list names of all SB namespaces in all resource groups in the given subscription ID
func ListServiceBusNamespaceNamesE(subscriptionID string) (*[]string, error) {
	sbNamespace, err := ListServiceBusNamespaceE(subscriptionID)

	if err != nil {
		return nil, err
	}

	results := make([]string, 0)
	for _, namespace := range *sbNamespace {
		results = append(results, *namespace.Name)
		if err != nil {
			return nil, err
		}
	}

	return &results, nil
}

// ListServiceBusNamespaceNames like ListServiceBusNamespaceNamesE but fails in the case an error is returned
func ListServiceBusNamespaceNames(t *testing.T, subscriptionID string) *[]string {
	results, err := ListServiceBusNamespaceNamesE(subscriptionID)
	if err != nil {
		t.Fatal(err)
	}

	return results
}

// ListServiceBusNamespaceIDsE list IDs of all SB namespaces in all resource groups in the given subscription ID
func ListServiceBusNamespaceIDsE(subscriptionID string) (*[]string, error) {
	sbNamespace, err := ListServiceBusNamespaceE(subscriptionID)

	if err != nil {
		return nil, err
	}

	results := make([]string, 0)
	for _, namespace := range *sbNamespace {
		results = append(results, *namespace.ID)
		if err != nil {
			return nil, err
		}
	}

	return &results, nil
}

// ListServiceBusNamespaceIDs like ListServiceBusNamespaceIDsE but fails in the case an error is returned
func ListServiceBusNamespaceIDs(t *testing.T, subscriptionID string) *[]string {
	results, err := ListServiceBusNamespaceIDsE(subscriptionID)
	if err != nil {
		t.Fatal(err)
	}

	return results
}

// ListServiceBusNamespaceByResourceGroupE list all SB namespaces in the given resource group
func ListServiceBusNamespaceByResourceGroupE(subscriptionID string, resourceGroup string) (*[]servicebus.SBNamespace, error) {
	nsClient, err := serviceBusNamespaceClientE(subscriptionID)
	if err != nil {
		return nil, err
	}

	iteratorSBNamespace, err := nsClient.ListByResourceGroupComplete(context.Background(), resourceGroup)
	if err != nil {
		return nil, err
	}

	results := make([]servicebus.SBNamespace, 0)

	for iteratorSBNamespace.NotDone() {
		results = append(results, iteratorSBNamespace.Value())
		err = iteratorSBNamespace.Next()
		if err != nil {
			return nil, err
		}
	}

	return &results, nil
}

// ListServiceBusNamespaceByResourceGroup like ListServiceBusNamespaceByResourceGroupE but fails in the case an error is returned
func ListServiceBusNamespaceByResourceGroup(t *testing.T, subscriptionID string, resourceGroup string) *[]servicebus.SBNamespace {
	results, err := ListServiceBusNamespaceByResourceGroupE(subscriptionID, resourceGroup)
	if err != nil {
		t.Fatal(err)
	}

	return results
}

// ListServiceBusNamespaceNamesByResourceGroupE list names of all SB namespaces in the given resource group
func ListServiceBusNamespaceNamesByResourceGroupE(subscriptionID string, resourceGroup string) (*[]string, error) {
	sbNamespace, err := ListServiceBusNamespaceByResourceGroupE(subscriptionID, resourceGroup)

	if err != nil {
		return nil, err
	}

	results := make([]string, 0)
	for _, namespace := range *sbNamespace {
		results = append(results, *namespace.Name)
		if err != nil {
			return nil, err
		}
	}

	return &results, nil
}

// ListServiceBusNamespaceNamesByResourceGroup like ListServiceBusNamespaceNamesByResourceGroupE but fails in the case an error is returned
func ListServiceBusNamespaceNamesByResourceGroup(t *testing.T, subscriptionID string, resourceGroup string) *[]string {
	results, err := ListServiceBusNamespaceNamesByResourceGroupE(subscriptionID, resourceGroup)
	if err != nil {
		t.Fatal(err)
	}

	return results
}

// ListServiceBusNamespaceIDsByResourceGroupE list IDs of all SB namespaces in the given resource group
func ListServiceBusNamespaceIDsByResourceGroupE(subscriptionID string, resourceGroup string) (*[]string, error) {
	sbNamespace, err := ListServiceBusNamespaceByResourceGroupE(subscriptionID, resourceGroup)

	if err != nil {
		return nil, err
	}

	results := make([]string, 0)
	for _, namespace := range *sbNamespace {
		results = append(results, *namespace.ID)
		if err != nil {
			return nil, err
		}
	}

	return &results, nil
}

// ListServiceBusNamespaceIDsByResourceGroup like ListServiceBusNamespaceIDsByResourceGroupE but fails in the case an error is returned
func ListServiceBusNamespaceIDsByResourceGroup(t *testing.T, subscriptionID string, resourceGroup string) *[]string {
	results, err := ListServiceBusNamespaceIDsByResourceGroupE(subscriptionID, resourceGroup)
	if err != nil {
		t.Fatal(err)
	}

	return results
}

// ListNamespaceAuthRulesE - authenticate namespace client and enumerates all values to get list of authorization rules for the given namespace name,
// automatically crossing page boundaries as required.
func ListNamespaceAuthRulesE(subscriptionID string, namespace string, resourceGroup string) (*[]string, error) {
	nsClient, err := serviceBusNamespaceClientE(subscriptionID)
	if err != nil {
		return nil, err
	}
	iteratorNamespaceRules, err := nsClient.ListAuthorizationRulesComplete(
		context.Background(), resourceGroup, namespace)

	if err != nil {
		return nil, err
	}

	results := make([]string, 0)
	for iteratorNamespaceRules.NotDone() {
		results = append(results, *(iteratorNamespaceRules.Value()).Name)
		err = iteratorNamespaceRules.Next()
		if err != nil {
			return nil, err
		}
	}
	return &results, nil
}

// ListNamespaceAuthRules - like ListNamespaceAuthRulesE but fails in the case an error is returned
func ListNamespaceAuthRules(t *testing.T, subscriptionID string, namespace string, resourceGroup string) *[]string {
	results, err := ListNamespaceAuthRulesE(subscriptionID, namespace, resourceGroup)
	if err != nil {
		t.Fatal(err)
	}

	return results
}

// ListNamespaceTopicsE - authenticate topic client and enumerates all values, automatically crossing page boundaries as required.
func ListNamespaceTopicsE(subscriptionID string, namespace string, resourceGroup string) (*[]servicebus.SBTopic, error) {
	tClient, err := serviceBusTopicClientE(subscriptionID)
	if err != nil {
		return nil, err
	}

	iteratorTopics, err := tClient.ListByNamespaceComplete(context.Background(), resourceGroup, namespace, nil, nil)
	if err != nil {
		return nil, err
	}

	results := make([]servicebus.SBTopic, 0)

	for iteratorTopics.NotDone() {
		results = append(results, iteratorTopics.Value())
		err = iteratorTopics.Next()
		if err != nil {
			return nil, err
		}
	}

	return &results, nil
}

// ListNamespaceTopics - like ListNamespaceTopicsE but fails in the case an error is returned
func ListNamespaceTopics(t *testing.T, subscriptionID string, namespace string, resourceGroup string) *[]servicebus.SBTopic {
	results, err := ListNamespaceTopicsE(subscriptionID, namespace, resourceGroup)
	if err != nil {
		t.Fatal(err)
	}

	return results
}

// ListTopicSubscriptionsE - authenticate subscriptions client and enumerates all values, automatically crossing page boundaries as required.
func ListTopicSubscriptionsE(subscriptionID string, namespace string, resourceGroup string, topicName string) ([]servicebus.SBSubscription, error) {
	sClient, err := serviceBusSubscriptionsClientE(subscriptionID)
	if err != nil {
		return nil, err
	}
	iteratorSubscription, err := sClient.ListByTopicComplete(context.Background(), resourceGroup, namespace, topicName, nil, nil)

	if err != nil {
		return nil, err
	}

	results := make([]servicebus.SBSubscription, 0)

	for iteratorSubscription.NotDone() {
		results = append(results, iteratorSubscription.Value())
		err = iteratorSubscription.Next()
		if err != nil {
			return nil, err
		}
	}
	return results, nil
}

// ListTopicSubscriptions - like ListTopicSubscriptionsE but fails in the case an error is returned
func ListTopicSubscriptions(t *testing.T, subscriptionID string, namespace string, resourceGroup string, topicName string) *[]servicebus.SBSubscription {
	results, err := ListTopicSubscriptionsE(subscriptionID, namespace, resourceGroup, topicName)
	if err != nil {
		t.Fatal(err)
	}

	return &results
}

// ListTopicSubscriptionsNameE - authenticate subscriptions client and enumerates all values to get list of subscriptions for the given topic name,
// automatically crossing page boundaries as required.
func ListTopicSubscriptionsNameE(subscriptionID string, namespace string, resourceGroup string, topicName string) (*[]string, error) {
	sClient, err := serviceBusSubscriptionsClientE(subscriptionID)
	if err != nil {
		return nil, err
	}
	iteratorSubscription, err := sClient.ListByTopicComplete(context.Background(), resourceGroup, namespace, topicName, nil, nil)

	if err != nil {
		return nil, err
	}

	results := make([]string, 0)
	for iteratorSubscription.NotDone() {
		results = append(results, *(iteratorSubscription.Value()).Name)
		err = iteratorSubscription.Next()
		if err != nil {
			return nil, err
		}
	}
	return &results, nil
}

// ListTopicSubscriptionsName - like ListTopicSubscriptionsNameE but fails in the case an error is returned
func ListTopicSubscriptionsName(t *testing.T, subscriptionID string, namespace string, resourceGroup string, topicName string) *[]string {
	results, err := ListTopicSubscriptionsNameE(subscriptionID, namespace, resourceGroup, topicName)
	if err != nil {
		t.Fatal(err)
	}

	return results
}

// ListTopicAuthRulesE - authenticate topic client and enumerates all values to get list of authorization rules for the given topic name,
// automatically crossing page boundaries as required.
func ListTopicAuthRulesE(subscriptionID string, namespace string, resourceGroup string, topicName string) (*[]string, error) {
	tClient, err := serviceBusTopicClientE(subscriptionID)
	if err != nil {
		return nil, err
	}
	iteratorTopicsRules, err := tClient.ListAuthorizationRulesComplete(
		context.Background(), resourceGroup, namespace, topicName)

	if err != nil {
		return nil, err
	}

	results := make([]string, 0)
	for iteratorTopicsRules.NotDone() {
		results = append(results, *(iteratorTopicsRules.Value()).Name)
		err = iteratorTopicsRules.Next()
		if err != nil {
			return nil, err
		}
	}
	return &results, nil
}

// ListTopicAuthRules - like ListTopicAuthRulesE but fails in the case an error is returned
func ListTopicAuthRules(t *testing.T, subscriptionID string, namespace string, resourceGroup string, topicName string) *[]string {
	results, err := ListTopicAuthRulesE(subscriptionID, namespace, resourceGroup, topicName)
	if err != nil {
		t.Fatal(err)
	}

	return results
}
