package test

import (
	"testing"

	"github.com/microsoft/terratest-abstraction/unit"
)

func appendDataFactoryTests(t *testing.T, description unit.ResourceDescription) {

	expectedDatafactoryApp := asMap(t, `{
		"identity":    [{ "type": "SystemAssigned" }]
	}`)
	description["module.data-factory.azurerm_data_factory.main"] = expectedDatafactoryApp
}
