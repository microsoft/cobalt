package test

import (
	"testing"

	"github.com/microsoft/cobalt/test-harness/terratest-extensions/modules/azure"
	"github.com/microsoft/terratest-abstraction/integration"
	"github.com/stretchr/testify/require"
)

// Verifies that the correct roles are assigned to the provisioned service principal
func verifyServicePrincipalRoleAssignments(t *testing.T, output integration.TerraformOutput) {
	actual := getActualRoleAssignmentsMap(t, output)
	expected := getExpectedRoleAssignmentsMap(output)

	// Note: there may be other role assignments added outside of this template. A good
	// example of this is the role assignment that enables the services to create
	// signed URLs for data that exists in storage accounts not managed by this
	// template.
	for k, v := range expected {
		require.Equal(t, v, actual[k], "Expected role assignment is incorrect!")
	}
}

// Queries Azure for the role assignments of the provisioned SP and transforms them into
// a simple-to-consume map type. The returned map will have a key equal to a scope and
// a value equal to the role name
func getActualRoleAssignmentsMap(t *testing.T, output integration.TerraformOutput) map[string]string {
	objectID := output["contributor_service_principal_id"].(string)
	assignments := azure.ListRoleAssignments(t, SubscriptionID, objectID)
	assignmentsMap := map[string]string{}

	for _, assignment := range *assignments {
		scope := assignment.Properties.Scope
		roleID := assignment.Properties.RoleDefinitionID
		roleName := azure.RoleName(t, SubscriptionID, *roleID)
		assignmentsMap[*scope] = roleName
	}

	return assignmentsMap
}

// Constructs the expected role assignments based off the Terraform output
func getExpectedRoleAssignmentsMap(output integration.TerraformOutput) map[string]string {
	expectedAssignments := map[string]string{}
	expectedAssignments[output["service_plan_id"].(string)] = "Contributor"
	expectedAssignments[output["container_registry_id"].(string)] = "Contributor"
	expectedAssignments[output["storage_account_id"].(string)] = "Storage Blob Data Contributor"

	for _, appID := range output["app_service_ids"].([]interface{}) {
		expectedAssignments[appID.(string)] = "Contributor"
	}

	return expectedAssignments
}
