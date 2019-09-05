package test

import (
	"fmt"
	"os"
	"testing"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/microsoft/cobalt/test-harness/infratests"
)

var workspace = fmt.Sprintf("az-hello-world-%s", random.UniqueId())
var prefix = fmt.Sprintf("az-hw-unit-tst-%s", random.UniqueId())
var datacenter = "eastus"

var tfOptions = &terraform.Options{
	TerraformDir: "../../",
	Upgrade:      true,
	Vars: map[string]interface{}{
		"name":                    prefix,
		"resource_group_location": datacenter,
	},
	BackendConfig: map[string]interface{}{
		"storage_account_name": os.Getenv("TF_VAR_remote_state_account"),
		"container_name":       os.Getenv("TF_VAR_remote_state_container"),
	},
}

func TestAzureSimple(t *testing.T) {
	testFixture := infratests.UnitTestFixture{
		GoTest:                t,
		TfOptions:             tfOptions,
		ExpectedResourceCount: 10,
		PlanAssertions:        nil,
		Workspace:             workspace,
		ExpectedResourceAttributeValues: infratests.ResourceDescription{
			"module.app_service.azurerm_app_service.appsvc[0]": map[string]interface{}{
				"app_settings": map[string]interface{}{
					"WEBSITES_ENABLE_APP_SERVICE_STORAGE": "false",
				},
				"site_config": []interface{}{
					map[string]interface{}{"linux_fx_version": "DOCKER|docker.io/appsvcsample/static-site:latest"},
				},
			},
			"module.service_plan.azurerm_app_service_plan.svcplan": map[string]interface{}{
				"kind":     "Linux",
				"reserved": true,
				"sku": []interface{}{
					map[string]interface{}{"size": "S1", "tier": "Standard"},
				},
			},
			"azurerm_resource_group.main": map[string]interface{}{
				"location": datacenter,
			},
		},
	}

	infratests.RunUnitTests(&testFixture)
}
