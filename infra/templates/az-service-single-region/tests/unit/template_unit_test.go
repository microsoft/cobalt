package test

import (
	"encoding/json"
	"os"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/microsoft/cobalt/test-harness/infratests"
)

var region = "eastus"
var workspace = "azsingleregion"

var tfOptions = &terraform.Options{
	TerraformDir: "../../",
	Upgrade:      true,
	Vars: map[string]interface{}{
		"resource_group_location": region,
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
	expectedAppServicePlan := asMap(t, `{
	}`)

	expectedAppGatewayPlan := asMap(t, `{
		"authentication_certificate": [{"name": "gateway-public-key"}],
		"frontend_port":              [{"port": 443}],
		"http_listener":              [{"protocol": "Https"}],
		"backend_http_settings":      [{"port": 443, "protocol": "Https"}],
		"probe":                      [{"protocol": "Https", "timeout": 30, "unhealthy_threshold": 3}],
		"sku":                        [{"capacity": 2, "name": "WAF_Medium", "tier": "WAF"}]
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

	testFixture := infratests.UnitTestFixture{
		GoTest:                t,
		TfOptions:             tfOptions,
		Workspace:             workspace,
		PlanAssertions:        nil,
		ExpectedResourceCount: 36,
		ExpectedResourceAttributeValues: infratests.ResourceDescription{
			"azurerm_resource_group.svcplan": map[string]interface{}{
				"location": region,
			},
			"module.app_gateway.data.azurerm_resource_group.appgateway":  map[string]interface{}{},
			"module.app_insight.data.azurerm_resource_group.appinsights": map[string]interface{}{},
			"module.app_service.azurerm_app_service_slot.appsvc_staging_slot[0]": map[string]interface{}{
				"name": "staging",
			},
			"module.app_service.azurerm_app_service.appsvc[0]":                             expectedAppServicePlan,
			"module.app_gateway.azurerm_application_gateway.appgateway":                    expectedAppGatewayPlan,
			"module.service_plan.azurerm_monitor_autoscale_setting.app_service_auto_scale": expectedAutoScalePlan,
		},
	}

	infratests.RunUnitTests(&testFixture)
}
