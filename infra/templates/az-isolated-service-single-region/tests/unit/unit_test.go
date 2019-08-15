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
	"github.com/microsoft/cobalt/test-harness/terratest-extensions/modules/azure"
)

var region = "eastus2"
var workspace = "az-isolated-" + strings.ToLower(random.UniqueId())

var adminSubscription = os.Getenv("ARM_SUBSCRIPTION_ID")
var aseName = "co-static-ase"
var aseResourceGroup = "co-static-ase-rg"

var tfOptions = &terraform.Options{
	TerraformDir: "../../",
	Upgrade:      true,
	Vars: map[string]interface{}{
		"resource_group_location": region,
		"deployment_targets": []interface{}{
			map[string]string{
				"app_name":                 "co-backend-api-1",
				"repository":               "https://github.com/erikschlegel/echo-server.git",
				"dockerfile":               "Dockerfile",
				"image_name":               "appsvcsample/echo-server-1",
				"image_release_tag_prefix": "release",
				"auth_client_id":           "",
			}, map[string]string{
				"app_name":                 "co-backend-api-2",
				"repository":               "https://github.com/erikschlegel/echo-server.git",
				"dockerfile":               "Dockerfile",
				"image_name":               "appsvcsample/echo-server-2",
				"image_release_tag_prefix": "release",
				"auth_client_id":           "",
			},
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
	expectedAppDevResourceGroup := asMap(t, `{
		"name":     "isolated-service-`+workspace+`-app-rg",
		"location": "`+region+`"
	}`)
	expectedAdminResourceGroup := asMap(t, `{
		"name":     "isolated-service-`+workspace+`-admin-rg",
		"location": "`+region+`"
	}`)
	expectedAppInsights := asMap(t, `{
		"name":                "isolated-service-`+workspace+`-ai",
		"application_type":    "Web",
		"resource_group_name": "isolated-service-`+workspace+`-admin-rg"
	}`)
	// expectedKeyVault := asMap(t, `{
	// 	"network_acls": [{
	// 		"bypass":         "None",
	// 		"default_action": "Deny",
	// 		"ip_rules": ["13.107.6.0/24", "13.107.9.0/24", "13.107.42.0/24", "13.107.43.0/24", "40.74.0.0/15", "40.76.0.0/14", "40.80.0.0/12", "40.96.0.0/12", "40.112.0.0/13", "40.120.0.0/14", "40.124.0.0/16", "40.125.0.0/17"]
	// 	}]
	// }`)

	// expectedAzureContainerRegistry := asMap(t, `{
	// 	"admin_enabled":       false,
	// 	"name":                "isolatedsazisolateacr",
	// 	"resource_group_name": "isolated-service-`+workspace+`-app-rg",
	// 	"sku":                 "Premium",
	// 	"network_rule_set":    [{
	// 		"default_action": "Deny",
	// 		"ip_rule": [{
	// 			"action": "Allow",
	// 			"ip_range": "13.107.6.0/24"
	// 		},
	// 		{
	// 			"action": "Allow",
	// 			"ip_range": "13.107.9.0/24"
	// 		},
	// 		{
	// 			"action": "Allow",
	// 			"ip_range": "13.107.42.0/24"
	// 		},
	// 		{
	// 			"action": "Allow",
	// 			"ip_range": "13.107.43.0/24"
	// 		},
	// 		{
	// 			"action": "Allow",
	// 			"ip_range": "40.74.0.0/15"
	// 		},
	// 		{
	// 			"action": "Allow",
	// 			"ip_range": "40.76.0.0/14"
	// 		},
	// 		{
	// 			"action": "Allow",
	// 			"ip_range": "40.80.0.0/12"
	// 		},
	// 		{
	// 			"action": "Allow",
	// 			"ip_range": "40.96.0.0/12"
	// 		},
	// 		{
	// 			"action": "Allow",
	// 			"ip_range": "40.112.0.0/13"
	// 		},
	// 		{
	// 			"action": "Allow",
	// 			"ip_range": "40.120.0.0/14"
	// 		},
	// 		{
	// 			"action": "Allow",
	// 			"ip_range": "40.124.0.0/16"
	// 		},
	// 		{
	// 			"action": "Allow",
	// 			"ip_range": "40.125.0.0/17"
	// 		}
	// 		]
	// 	}]
	// }`)
	expectedAppServiceEnvID := fmt.Sprintf(
		"/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Web/hostingEnvironments/%s",
		adminSubscription,
		aseResourceGroup,
		aseName)
	expectedAppServicePlan := asMap(t, `{
		"app_service_environment_id": "`+expectedAppServiceEnvID+`", 
		"kind":                       "Linux",
		"name":                       "isolated-service-`+workspace+`-sp",
		"reserved":                   true,
		"resource_group_name":        "isolated-service-`+workspace+`-admin-rg",
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
		"name": "co-backend-api-%d-%s",
		"resource_group_name": "isolated-service-%s-admin-rg",
		"site_config": [{
			"always_on": true
		}]
	}`
	expectedAppService1 := asMap(t, fmt.Sprintf(expectedAppServiceSchema, 1, workspace, workspace))
	expectedAppService2 := asMap(t, fmt.Sprintf(expectedAppServiceSchema, 2, workspace, workspace))

	testFixture := infratests.UnitTestFixture{
		GoTest:                t,
		TfOptions:             tfOptions,
		Workspace:             workspace,
		PlanAssertions:        nil,
		ExpectedResourceCount: 42,
		ExpectedResourceAttributeValues: infratests.ResourceDescription{
			"azurerm_resource_group.app_rg":   expectedAppDevResourceGroup,
			"azurerm_resource_group.admin_rg": expectedAdminResourceGroup,
			// "module.keyvault.azurerm_key_vault.keyvault":                                   expectedKeyVault,
			"module.service_plan.azurerm_app_service_plan.svcplan":                         expectedAppServicePlan,
			"module.app_insights.azurerm_application_insights.appinsights":                 expectedAppInsights,
			"module.app_service.azurerm_app_service.appsvc[0]":                             expectedAppService1,
			"module.app_service.azurerm_app_service.appsvc[1]":                             expectedAppService2,
			"module.app_service.azurerm_app_service_slot.appsvc_staging_slot[0]":           expectedStagingSlot,
			"module.app_service.azurerm_app_service_slot.appsvc_staging_slot[1]":           expectedStagingSlot,
			"module.service_plan.azurerm_monitor_autoscale_setting.app_service_auto_scale": expectedAutoScalePlan,
			// "module.container_registry.azurerm_container_registry.container_registry":      expectedAzureContainerRegistry,

			// These are basically existence checks. Nothing interesting to inspect for the resources
			"module.app_service.null_resource.acr_webhook_creation[0]": nil,
			"module.app_service.null_resource.acr_webhook_creation[1]": nil,
		},
	}

	// Required because there is a VNET query done by the template that requires a call to Azure CLI
	azure.CliServicePrincipalLogin(t)
	infratests.RunUnitTests(&testFixture)
}
