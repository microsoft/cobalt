package test

import (
	"encoding/json"
	"fmt"
	"os"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/microsoft/cobalt/test-harness/infratests"
)

var region = "eastus2"
var workspace = "az-isolated-" + strings.ToLower(random.UniqueId())

var admin_subscription = os.Getenv("TF_VAR_admin_subscription_id")
var ase_name = os.Getenv("TF_VAR_app_service_environment_name")
var ase_resource_group = os.Getenv("TF_VAR_app_service_environment_resource_group")

var tfOptions = &terraform.Options{
	TerraformDir: "../../",
	Upgrade:      true,
	Vars: map[string]interface{}{
		"resource_group_location": region,
		"ase_subscription_id":     admin_subscription,
		"ase_name":                ase_name,
		"ase_resource_group":      ase_resource_group,
		"app_service_name": map[string]interface{}{
			"cobalt-backend-api-1": "appsvcsample/static-site:latest",
			"cobalt-backend-api-2": "appsvcsample/static-site:latest",
		},
	},
	BackendConfig: map[string]interface{}{
		"storage_account_name": os.Getenv("TF_VAR_remote_state_account"),
		"container_name":       os.Getenv("TF_VAR_remote_state_container"),
	},
}

// helper function to parse blocks of JSON into a generic Go map
func asMap(t *testing.T, jsonString string) map[string]interface{} {
	var theMap map[string]interface{}
	if err := json.Unmarshal([]byte(jsonString), &theMap); err != nil {
		t.Fatal(err)
	}
	return theMap
}

func TestTemplate(t *testing.T) {
	expectedStagingSlot := asMap(t, `{"name":"staging"}`)
	expectedResourceGroup := asMap(t, `{
		"name":     "isolated-service-`+workspace+`-rg",
		"location": "`+region+`"
	}`)
	expectedAppInsights := asMap(t, `{
		"name":                "isolated-service-`+workspace+`-ai",
		"application_type":    "Web",
		"resource_group_name": "isolated-service-`+workspace+`-rg"
	}`)
	expectedAppServiceEnvId := fmt.Sprintf(
		"/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Web/hostingEnvironments/%s",
		admin_subscription,
		ase_resource_group,
		ase_name)
	expectedAppServicePlan := asMap(t, `{
		"app_service_environment_id": "`+expectedAppServiceEnvId+`", 
		"kind":                       "Linux",
		"name":                       "isolated-service-`+workspace+`-sp",
		"reserved":                   true,
		"resource_group_name":        "isolated-service-`+workspace+`-rg",
		"sku": [{ "capacity": 1, "size": "I1", "tier": "Isolated" }]
	}`)
	expectedAutoScalePlan := asMap(t, `{
		"enabled": true,
		"notification": [{
			"email": [{
				"send_to_subscription_administrator":    true,
				"send_to_subscription_co_administrator": true
			}]
		}],
		"profile": [{
			"rule": [{
				"metric_trigger": [{
					"metric_name":      "CpuPercentage",
					"operator":         "GreaterThan",
					"statistic":        "Average",
					"threshold":        70,
					"time_aggregation": "Average",
					"time_grain":       "PT1M",
					"time_window":      "PT5M"
				}],
				"scale_action": [{
					"cooldown":  "PT10M",
					"direction": "Increase",
					"type":      "ChangeCount",
					"value":     1
				}]
			  },{
				"metric_trigger": [{
					"metric_name":      "CpuPercentage",
					"operator":         "GreaterThan",
					"statistic":        "Average",
					"threshold":        25,
					"time_aggregation": "Average",
					"time_grain":       "PT1M",
					"time_window":      "PT5M"
				}],
				"scale_action": [{
					"cooldown":  "PT1M",
					"direction": "Decrease",
					"type":      "ChangeCount",
					"value":     1
				}]
			}]
		}]
	}`)
	expectedAppServiceSchema := `{
		"identity": [{ "type": "SystemAssigned" }],
		"name": "cobalt-backend-api-%d-%s",
		"resource_group_name": "isolated-service-%s-rg",
		"site_config": [{
			"always_on": true,
			"linux_fx_version": "DOCKER|docker.io/appsvcsample/static-site:latest"
		}]
	}`
	expectedAppService1 := asMap(t, fmt.Sprintf(expectedAppServiceSchema, 1, workspace, workspace))
	expectedAppService2 := asMap(t, fmt.Sprintf(expectedAppServiceSchema, 2, workspace, workspace))

	testFixture := infratests.UnitTestFixture{
		GoTest:                t,
		TfOptions:             tfOptions,
		Workspace:             workspace,
		PlanAssertions:        nil,
		ExpectedResourceCount: 12,
		ExpectedResourceAttributeValues: infratests.ResourceDescription{
			"azurerm_resource_group.rg":                                                    expectedResourceGroup,
			"module.service_plan.azurerm_app_service_plan.svcplan":                         expectedAppServicePlan,
			"module.app_insight.azurerm_application_insights.appinsights":                  expectedAppInsights,
			"module.app_service.azurerm_app_service.appsvc[0]":                             expectedAppService1,
			"module.app_service.azurerm_app_service.appsvc[1]":                             expectedAppService2,
			"module.app_service.azurerm_app_service_slot.appsvc_staging_slot[0]":           expectedStagingSlot,
			"module.app_service.azurerm_app_service_slot.appsvc_staging_slot[1]":           expectedStagingSlot,
			"module.service_plan.azurerm_monitor_autoscale_setting.app_service_auto_scale": expectedAutoScalePlan,
		},
	}

	infratests.RunUnitTests(&testFixture)
}
