package test

import (
	"testing"

	"github.com/microsoft/terratest-abstraction/unit"
)

func appendFunctionAppTests(t *testing.T, description unit.ResourceDescription) {

	expectedFunctionApp := asMap(t, `{
		  "enable_builtin_logging": true,
		  "enabled": true,
		  "https_only": false,
		  "version": "~3"
	}`)

	description["module.function_app.azurerm_function_app.main[0]"] = expectedFunctionApp
}
