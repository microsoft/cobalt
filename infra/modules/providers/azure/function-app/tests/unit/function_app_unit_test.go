package unit

import (
	"encoding/json"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/random"
	tests "github.com/microsoft/cobalt/infra/modules/providers/azure/function-app/tests"
	"github.com/microsoft/terratest-abstraction/unit"
)

var resourceCount = 2
var resourceGroupName = "Test-Terraform-rg"

//TestFunctionAppDeploymentUnit unit test case
func TestFunctionAppDeploymentUnit(t *testing.T) {

	expectedFunctionApp := map[string]interface{}{
		"name":                "funcname",
		"resource_group_name": resourceGroupName,
		"location":            "eastus",
		"version":             "~2",
		"tags": map[string]interface{}{
			"environment": "dev"},
		"https_only": false,

		"site_config": []interface{}{
			map[string]interface{}{
				"linux_fx_version": "DOCKER|docker.io/",
				"always_on":        true,
			},
		},

		"app_settings": map[string]interface{}{
			"FUNCTIONS_EXTENSION_VERSION":         "~2",
			"FUNCTIONS_WORKER_RUNTIME":            "dotnet",
			"WEBSITES_ENABLE_APP_SERVICE_STORAGE": "false",
			"APPINSIGHTS_INSTRUMENTATIONKEY":      "...",
		},

		"identity": []interface{}{
			map[string]interface{}{"type": "SystemAssigned"},
		},
	}

	expectedTemplateDeployment := map[string]interface{}{
		"name":                "access_restriction",
		"resource_group_name": resourceGroupName,
		"parameters": map[string]interface{}{
			"service_name":                   "func",
			"vnet_subnet_id":                 "/subscriptions/####/resourceGroups/#####/providers/Microsoft.Network/virtualNetworks/####/subnets/####",
			"access_restriction_name":        "vnet_restriction",
			"access_restriction_description": "blocking public traffic to function app",
		},
		"deployment_mode": "Incremental",
	}

	testFixture := unit.UnitTestFixture{
		GoTest:                t,
		TfOptions:             tests.FunctionAppTFOptions,
		PlanAssertions:        nil,
		ExpectedResourceCount: resourceCount,
		ExpectedResourceAttributeValues: unit.ResourceDescription{
			"azurerm_function_app.main[0]":        expectedFunctionApp,
			"azurerm_template_deployment.main[0]": expectedTemplateDeployment,
		},
	}

	unit.RunUnitTests(&testFixture)

}
