package test

import (
	"encoding/json"
	"fmt"
	"os"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/microsoft/cobalt/test-harness/terratest-extensions/modules/azure"
	"github.com/microsoft/terratest-abstraction/unit"
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
		"resource_ip_whitelist": []string{
			"1.2.3.4/32",
			"5.6.0.0/16"},
		"resource_group_location": region,
		"ase_subscription_id":     adminSubscription,
		"ase_name":                aseName,
		"ase_resource_group":      aseResourceGroup,
		"authn_deployment_targets": []interface{}{
			map[string]string{
				"app_name":                 "co-frontend-api-1",
				"image_name":               "appsvcsample/echo-server-1",
				"image_release_tag_prefix": "release",
			},
		},
		"unauthn_deployment_targets": []interface{}{
			map[string]string{
				"app_name":                 "co-backend-api-1",
				"image_name":               "appsvcsample/echo-server-2",
				"image_release_tag_prefix": "release",
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
	expectedAppDevResourceGroup := asMap(t, `{
		"location": "`+region+`"
	}`)
	expectedAdminResourceGroup := asMap(t, `{
		"location": "`+region+`"
	}`)
	expectedAppInsights := asMap(t, `{
		"application_type":    "Web"
	}`)
	expectedKeyVault := asMap(t, `{
		"network_acls": [{
			"bypass":         "None",
			"default_action": "Deny",
			"ip_rules": ["1.2.3.4/32", "5.6.0.0/16"]
		}]
	}`)

	expectedAzureContainerRegistry := asMap(t, `{
		"admin_enabled":       false,
		"sku":                 "Premium",
		"network_rule_set":    [{
			"default_action": "Deny",
			"ip_rule": [{
				"action": "Allow",
				"ip_range": "1.2.3.4/32"
			},
			{
				"action": "Allow",
				"ip_range": "5.6.0.0/16"
			}]
		}]
	}`)

	expectedAppServiceEnvID := fmt.Sprintf(
		"/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Web/hostingEnvironments/%s",
		adminSubscription,
		aseResourceGroup,
		aseName)
	expectedAppServicePlan := asMap(t, `{
		"app_service_environment_id": "`+expectedAppServiceEnvID+`",
		"kind":                       "Linux",
		"reserved":                   true,
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
		"identity":    [{ "type": "SystemAssigned" }],
		"enabled":     true,
		"site_config": [{
			"always_on":         true,
			"linux_fx_version": "DOCKER"
		}]
	}`
	expectedAppService := asMap(t, expectedAppServiceSchema)

	expectedAppServiceSlot := asMap(t, `{
		"name":        "staging",
		"identity":    [{ "type": "SystemAssigned" }],
		"enabled":     true,
		"site_config": [{
			"always_on":         true,
			"linux_fx_version": "DOCKER"
		}]
	}`)

	expectedAppServiceKVPolicies := asMap(t, `{
		"certificate_permissions": ["get", "list"],
		"key_permissions":         ["get", "list"],
		"secret_permissions":      ["get", "list"]
	}`)

	expectedDeploymentServicePrincipalKVPolicies := asMap(t, `{
		"certificate_permissions": ["create", "delete", "get", "list"],
		"key_permissions":         ["create", "delete", "get"],
		"secret_permissions":      ["delete", "get", "set", "list"]
	}`)

	testFixture := unit.UnitTestFixture{
		GoTest:                t,
		TfOptions:             tfOptions,
		Workspace:             workspace,
		PlanAssertions:        nil,
		ExpectedResourceCount: 57,
		ExpectedResourceAttributeValues: unit.ResourceDescription{
			"module.keyvault.azurerm_key_vault.keyvault":                                                                               expectedKeyVault,
			"module.container_registry.azurerm_container_registry.container_registry":                                                  expectedAzureContainerRegistry,
			"azurerm_resource_group.app_rg":                                                                                            expectedAppDevResourceGroup,
			"azurerm_resource_group.admin_rg":                                                                                          expectedAdminResourceGroup,
			"module.service_plan.azurerm_app_service_plan.svcplan":                                                                     expectedAppServicePlan,
			"module.app_insights.azurerm_application_insights.appinsights":                                                             expectedAppInsights,
			"module.app_service.azurerm_app_service.appsvc[0]":                                                                         expectedAppService,
			"module.authn_app_service.azurerm_app_service.appsvc[0]":                                                                   expectedAppService,
			"module.app_service.azurerm_app_service_slot.appsvc_staging_slot[0]":                                                       expectedAppServiceSlot,
			"module.authn_app_service.azurerm_app_service_slot.appsvc_staging_slot[0]":                                                 expectedAppServiceSlot,
			"module.service_plan.azurerm_monitor_autoscale_setting.app_service_auto_scale[0]":                                          expectedAutoScalePlan,
			"module.app_service_keyvault_access_policy.azurerm_key_vault_access_policy.keyvault[0]":                                    expectedAppServiceKVPolicies,
			"module.authn_app_service_keyvault_access_policy.azurerm_key_vault_access_policy.keyvault[0]":                              expectedAppServiceKVPolicies,
			"module.keyvault.module.deployment_service_principal_keyvault_access_policies.azurerm_key_vault_access_policy.keyvault[0]": expectedDeploymentServicePrincipalKVPolicies,
		},
	}

	// Required because there is a VNET query done by the template that requires a call to Azure CLI
	azure.CliServicePrincipalLogin(t)
	unit.RunUnitTests(&testFixture)
}
