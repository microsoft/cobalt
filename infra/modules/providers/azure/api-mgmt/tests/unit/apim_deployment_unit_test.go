package test

import (
	"fmt"
	"testing"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/microsoft/cobalt/test-harness/infratests"
)

var workspace = fmt.Sprintf("apim-unit-test-%s", random.UniqueId())
var datacenter = "eastus"

var tfOptions = &terraform.Options{
	TerraformDir: "../../",
	Upgrade:      true,
	VarFiles:     []string{"./tests/testing.tfvars"},
}

func TestAzureSimple(t *testing.T) {
	testFixture := infratests.UnitTestFixture{
		GoTest:                t,
		TfOptions:             tfOptions,
		ExpectedResourceCount: 15,
		PlanAssertions:        nil,
		ExpectedResourceAttributeValues: infratests.ResourceDescription{
			"azurerm_api_management.apim_service": map[string]interface{}{
				"name":     "cobalt-apim-service",
				"sku_name": "Developer_1",
				"tags":     map[string]interface{}{"Environment": "dev"},
				"identity": []interface{}{
					map[string]interface{}{"type": "SystemAssigned"},
				},
			},
			"azurerm_api_management_api.api[0]": map[string]interface{}{
				"name":         "petstore",
				"path":         "petstore",
				"display_name": "petstore",
				"version":      "v1",
				"revision":     "1",
				"protocols":    []interface{}{"http", "https"},
			},
			"azurerm_api_management_api_version_set.api_version_set[0]": map[string]interface{}{
				"name":              "testversionset",
				"display_name":      "testversionset",
				"versioning_scheme": "Segment",
			},
			"azurerm_api_management_product.product[0]": map[string]interface{}{
				"product_id":            "testproduct",
				"display_name":          "testproduct",
				"subscription_required": false,
				"approval_required":     false,
				"published":             true,
			},
			"azurerm_api_management_group.group[0]": map[string]interface{}{
				"name":         "testgroup",
				"display_name": "testgroup",
				"type":         "custom",
			},
			"azurerm_api_management_property.named_value[0]": map[string]interface{}{
				"name":         "testnamedvalue",
				"display_name": "test_named_value",
				"secret":       false,
				"tags":         []interface{}{"testtag"},
				"value":        "a test value",
			},
			"azurerm_api_management_backend.backend[0]": map[string]interface{}{
				"name":        "testbackend",
				"description": "a test backend",
				"protocol":    "http",
				"url":         "https://petstore.swagger.io/v2",
			},
		},
	}

	infratests.RunUnitTests(&testFixture)
}
