package unit

import (
	"encoding/json"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/random"
	tests "github.com/microsoft/cobalt/infra/modules/providers/azure/network/tests"
	"github.com/microsoft/terratest-abstraction/unit"
)

var resourceCount = 3

// helper function to parse blocks of JSON into a generic Go map
func asMap(t *testing.T, jsonString string) map[string]interface{} {
	var theMap map[string]interface{}
	if err := json.Unmarshal([]byte(jsonString), &theMap); err != nil {
		t.Fatal(err)
	}
	return theMap
}

func TestNetworkDeployment_Unit(t *testing.T) {

	expectedVnetResult := asMap(t, `{
		"name":                 "`+tests.VnetName+`",
		"resource_group_name": "`+tests.ResourceGroupName+`",
		"address_space":       ["`+tests.AddressSpace+`"]
	  }`)

	expectedSubnetResult := asMap(t, `{
		"name":                 "`+tests.SubnetName+`",
		"resource_group_name":  "`+tests.ResourceGroupName+`",
		"address_prefix":       ["`+tests.AddressPrefix+`"],
		"virtual_network_name": "`+tests.VnetName+`"
	}`)

	testFixture := unit.UnitTestFixture{
		GoTest:                t,
		TfOptions:             tests.NetworkTFOptions,
		PlanAssertions:        nil,
		ExpectedResourceCount: resourceCount,
		ExpectedResourceAttributeValues: unit.ResourceDescription{
			"azurerm_virtual_network.vnet": expectedVnetResult,
			"azurerm_subnet.subnet[0]":     expectedSubnetResult,
		},
	}

	unit.RunUnitTests(&testFixture)
}
