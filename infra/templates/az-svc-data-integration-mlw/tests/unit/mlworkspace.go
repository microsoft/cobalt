package test

import (
	"testing"

	"github.com/microsoft/terratest-abstraction/unit"
)

func appendMLWorkspaceTests(t *testing.T, description unit.ResourceDescription) {

	expectedMLWorkspaceResult := map[string]interface{}{
		"name":                "demo0012",
		"resource_group_name": "azmltest",
		"sku_name":            "Enterprise",
	}
	description["module.ml_workspace.azurerm_machine_learning_workspace.mlworkspace"] = expectedMLWorkspaceResult
}
