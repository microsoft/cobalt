package unit

import (
	"encoding/json"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/random"
	tests "github.com/microsoft/cobalt/infra/modules/providers/azure/data-factory/tests"
	"github.com/microsoft/terratest-abstraction/unit"
)


// helper function to parse blocks of JSON into a generic Go map
func asMap(t *testing.T, jsonString string) map[string]interface{} {
	var theMap map[string]interface{}
	if err := json.Unmarshal([]byte(jsonString), &theMap); err != nil {
		t.Fatal(err)
	}
	return theMap
}

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

	expectedDatasetSQL := map[string]interface{}{
		"name": "testsql",
	}

	expectedLinkedSQL := map[string]interface{}{
		"name":              "testlinkedsql",
		"connection_string": "connectionstring",
	}

	testFixture := unit.UnitTestFixture{
		GoTest:                t,
		TfOptions:             tests.DataFactoryTFOptions,
<<<<<<< HEAD
		Workspace:             workspace,
=======
>>>>>>> e5dbe99f950dc3f35581d614af19b94614b3706f
		PlanAssertions:        nil,
		ExpectedResourceCount: 6,
		ExpectedResourceAttributeValues: unit.ResourceDescription{
			"azurerm_data_factory.main":                             expectedDataFactory,
			"azurerm_data_factory_integration_runtime_managed.main": expectedDFIntRunTime,
			"azurerm_data_factory_pipeline.main":                    expectedPipeline,
			"azurerm_data_factory_trigger_schedule.main":            expectedTrigger,
			"azurerm_data_factory_dataset_sql_server_table.main":    expectedDatasetSQL,
			"azurerm_data_factory_linked_service_sql_server.main":   expectedLinkedSQL,
		},
	}

	unit.RunUnitTests(&testFixture)
}
