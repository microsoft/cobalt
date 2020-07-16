package test

import (
	"os"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/microsoft/terratest-abstraction/unit"
)

var tfOptions = &terraform.Options{
	TerraformDir: "../../",
	Upgrade:      true,
	Vars: map[string]interface{}{
		"resource_group_location": region,
		"prefix":                  prefix,
		"app_services": []interface{}{
			map[string]interface{}{
				"app_name":         "smpl",
				"image":            *new(string),
				"app_command_line": *new(string),
				"linux_fx_version": *new(string),
				"app_settings":     make(map[string]string, 0),
			},
		},
	},
	BackendConfig: map[string]interface{}{
		"storage_account_name": os.Getenv("TF_VAR_remote_state_account"),
		"container_name":       os.Getenv("TF_VAR_remote_state_container"),
	},
}

func TestTemplate(t *testing.T) {
	expectedAppDevResourceGroup := asMap(t, `{
		"location": "`+region+`"
	}`)

	expectedMlDevResourceGroup := asMap(t, `{
		"location": "`+region+`"
	}`)

	expectedAppInsights := asMap(t, `{
		"application_type":    "web"
	}`)

	resourceDescription := unit.ResourceDescription{
		"azurerm_resource_group.app_rg":                                expectedAppDevResourceGroup,
		"module.app_insights.azurerm_application_insights.appinsights": expectedAppInsights,
	}

	resourceWorkspaceDescription := unit.ResourceDescription{
		"azurerm_resource_group.mlw_rg":                                expectedMlDevResourceGroup,
		"module.app_insights.azurerm_application_insights.appinsights": expectedAppInsights,
	}

	//appendAutoScaleTests(t, resourceDescription)
	appendKeyVaultTests(t, resourceDescription)
	appendStorageTests(t, resourceDescription)
	appendMLWorkspaceTests(t, resourceWorkspaceDescription)
	appendDataFactoryTests(t, resourceDescription)
	appendFunctionAppTests(t, resourceDescription)
	appendCosmosDbTests(t, resourceDescription)

	testFixture := unit.UnitTestFixture{
		GoTest:                          t,
		TfOptions:                       tfOptions,
		Workspace:                       workspace,
		PlanAssertions:                  nil,
		ExpectedResourceCount:           81,
		ExpectedResourceAttributeValues: resourceDescription,
	}

	unit.RunUnitTests(&testFixture)
}
