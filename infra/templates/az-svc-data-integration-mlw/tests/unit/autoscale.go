package test

import (
	"testing"

	"github.com/microsoft/terratest-abstraction/unit"
)

func appendAutoScaleTests(t *testing.T, description unit.ResourceDescription) {
	v := asMap(t, `{
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
			}]
		}]
	}`)

	k := "module.service_plan.azurerm_monitor_autoscale_setting.app_service_auto_scale"
	description[k] = v
}
