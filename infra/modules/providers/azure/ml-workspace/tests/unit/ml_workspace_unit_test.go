package unit

import (
	"encoding/json"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/random"
	tests "github.com/microsoft/cobalt/infra/modules/providers/azure/ml-workspace/tests"
	"github.com/microsoft/terratest-abstraction/unit"
)

var resourceCount = 1
var workspace = "sample-" + strings.ToLower(random.UniqueId())

// helper function to parse blocks of JSON into a generic Go map
func asMap(t *testing.T, jsonString string) map[string]interface{} {
	var theMap map[string]interface{}
	if err := json.Unmarshal([]byte(jsonString), &theMap); err != nil {
		t.Fatal(err)
	}
	return theMap
}

func TestAzureMLWorkspaceDeployment_Unit(t *testing.T) {

	expectedResult := map[string]interface{}{
		"name":                "demo0012",
		"resource_group_name": "azmltest",
		"sku_name":            "Enterprise",
	}
	testFixture := unit.UnitTestFixture{
		GoTest:                t,
		TfOptions:             tests.MLWorkspaceTFOptions,
		Workspace:             workspace,
		PlanAssertions:        nil,
		ExpectedResourceCount: resourceCount,
		ExpectedResourceAttributeValues: unit.ResourceDescription{
			"azurerm_machine_learning_workspace.mlworkspace": expectedResult,
		},
	}

	unit.RunUnitTests(&testFixture)
}
