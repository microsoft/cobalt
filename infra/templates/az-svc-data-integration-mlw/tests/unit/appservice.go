package test

import (
	"testing"

	"github.com/microsoft/terratest-abstraction/unit"
)

func appendAppServiceTests(t *testing.T, description unit.ResourceDescription) {

	expectedAppServicePlan := asMap(t, `{
		"kind":                       "Linux",
		"reserved":                   true,
		"sku": [{ "capacity": 1, "size": "P3v2", "tier": "PremiumV2" }]
	}`)
	description["module.service_plan.azurerm_app_service_plan.svcplan"] = expectedAppServicePlan

	expectedAppService := asMap(t, `{
		"identity":    [{ "type": "SystemAssigned" }],
		"enabled":     true,
		"site_config": [{
			"always_on":         true
		}]
	}`)
	description["module.app_service.azurerm_app_service.appsvc[0]"] = expectedAppService

	expectedAppServiceSlot := asMap(t, `{
		"name":        "staging",
		"identity":    [{ "type": "SystemAssigned" }],
		"enabled":     true,
		"site_config": [{
			"always_on":         true
		}]
	}`)
	description["module.app_service.azurerm_app_service_slot.appsvc_staging_slot[0]"] = expectedAppServiceSlot
}
