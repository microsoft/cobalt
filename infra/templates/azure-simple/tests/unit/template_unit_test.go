package test

import (
	"os"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/microsoft/cobalt/test-harness/infratests"
)

var region = "eastus"
var workspace = "azsimple"

var tf_options = &terraform.Options{
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

func TestTemplate(t *testing.T) {
	testFixture := infratests.UnitTestFixture{
		GoTest:                t,
		TfOptions:             tf_options,
		Workspace:             workspace,
		PlanAssertions:        nil,
		ExpectedResourceCount: 28,
		ExpectedResourceAttributeValues: infratests.ResourceDescription{
			"azurerm_resource_group.svcplan": infratests.AttributeValueMapping{
				"location": region,
				"name":     "cobalt-az-simple-" + workspace,
			},
			"azurerm_app_service_slot.appsvc_staging_slot": infratests.AttributeValueMapping{
				"name": "staging",
			},
			"azurerm_app_service.appsvc": infratests.AttributeValueMapping{
				"name":                           "cobalt-backend-api-" + workspace,
				"site_config.0.linux_fx_version": "DOCKER|msftcse/cobalt-azure-simple:0.1",
			},
			"data.azurerm_resource_group.appgateway": infratests.AttributeValueMapping{
				"name": "cobalt-az-simple-" + workspace,
			},
			"azurerm_application_gateway.appgateway": infratests.AttributeValueMapping{
				"authentication_certificate.0.name": "gateway-public-key",
				"frontend_port.0.port":              "443",
				"http_listener.0.protocol":          "Https",
				"backend_http_settings.0.port":      "443",
				"backend_http_settings.0.protocol":  "Https",
				"probe.0.protocol":                  "Https",
				"probe.0.timeout":                   "30",
				"probe.0.unhealthy_threshold":       "3",
				"sku.0.capacity":                    "2",
				"sku.0.name":                        "WAF_Medium",
				"sku.0.tier":                        "WAF",
			},
			"data.azurerm_resource_group.appinsights": infratests.AttributeValueMapping{
				"name": "cobalt-az-simple-" + workspace,
			},
			"azurerm_monitor_autoscale_setting.app_service_auto_scale": infratests.AttributeValueMapping{
				"enabled": "true",
				"name":    "cobalt-az-simple-" + workspace + "-sp-autoscale",
				"notification.0.email.0.send_to_subscription_administrator":    "true",
				"notification.0.email.0.send_to_subscription_co_administrator": "true",
				"profile.0.rule.0.metric_trigger.0.metric_name":                "CpuPercentage",
				"profile.0.rule.0.metric_trigger.0.operator":                   "GreaterThan",
				"profile.0.rule.0.metric_trigger.0.statistic":                  "Average",
				"profile.0.rule.0.metric_trigger.0.threshold":                  "70",
				"profile.0.rule.0.metric_trigger.0.time_aggregation":           "Average",
				"profile.0.rule.0.metric_trigger.0.time_grain":                 "PT1M",
				"profile.0.rule.0.metric_trigger.0.time_window":                "PT5M",
				"profile.0.rule.0.scale_action.0.cooldown":                     "PT10M",
				"profile.0.rule.0.scale_action.0.direction":                    "Increase",
				"profile.0.rule.0.scale_action.0.type":                         "ChangeCount",
				"profile.0.rule.0.scale_action.0.value":                        "1",
				"profile.0.rule.1.metric_trigger.0.metric_name":                "CpuPercentage",
				"profile.0.rule.1.metric_trigger.0.operator":                   "GreaterThan",
				"profile.0.rule.1.metric_trigger.0.statistic":                  "Average",
				"profile.0.rule.1.metric_trigger.0.threshold":                  "25",
				"profile.0.rule.1.metric_trigger.0.time_aggregation":           "Average",
				"profile.0.rule.1.metric_trigger.0.time_grain":                 "PT1M",
				"profile.0.rule.1.metric_trigger.0.time_window":                "PT5M",
				"profile.0.rule.1.scale_action.0.cooldown":                     "PT1M",
				"profile.0.rule.1.scale_action.0.direction":                    "Decrease",
				"profile.0.rule.1.scale_action.0.type":                         "ChangeCount",
				"profile.0.rule.1.scale_action.0.value":                        "1",
			},
		},
	}

	infratests.RunUnitTests(&testFixture)
}
