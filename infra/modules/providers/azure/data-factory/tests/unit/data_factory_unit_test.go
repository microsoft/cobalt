package unit

import (
	"testing"
	tests "github.com/microsoft/cobalt/infra/modules/providers/azure/data-factory/tests"
	"github.com/microsoft/terratest-abstraction/unit"
)

func TestTemplate(t *testing.T) {

	expectedDataFactory := map[string]interface{}{
		"name":                "adftest",
		"resource_group_name": tests.ResourceGroupName,
		"identity": []interface{}{
			map[string]interface{}{"type": "SystemAssigned"},
		},
	}

	expectedDFIntRunTime := map[string]interface{}{
		"name":                             "adfrttest",
		"node_size":                        "Standard_D2_v3",
		"number_of_nodes":                  1.0,
		"edition":                          "Standard",
		"max_parallel_executions_per_node": 1.0,
		"vnet_integration": []interface{}{
			map[string]interface{}{
				"vnet_id":     "/subscriptions/resourceGroups/providers/Microsoft.Network/virtualNetworks/testvnet",
				"subnet_name": "default",
			},
		},
	}

	expectedPipeline := map[string]interface{}{
		"name": "testpipeline",
	}

	expectedTrigger := map[string]interface{}{
		"name":      "testtrigger",
		"interval":  1.0,
		"frequency": "Minute",
	}

	testFixture := unit.UnitTestFixture{
		GoTest:                t,
		TfOptions:             tests.DataFactoryTFOptions,
		PlanAssertions:        nil,
		ExpectedResourceCount: 4,
		ExpectedResourceAttributeValues: unit.ResourceDescription{
			"azurerm_data_factory.main":                             expectedDataFactory,
			"azurerm_data_factory_integration_runtime_managed.main": expectedDFIntRunTime,
			"azurerm_data_factory_pipeline.main":                    expectedPipeline,
			"azurerm_data_factory_trigger_schedule.main":            expectedTrigger,
		},
	}

	unit.RunUnitTests(&testFixture)
}
