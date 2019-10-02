package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestDoesNotRequireTailList(t *testing.T) {
	expectedList := []string{"a.a.a.a/aa", "b.b.b.b/bb"}
	terraformOptions := &terraform.Options{
		TerraformDir: "../..",
		Vars: map[string]interface{}{
			"comma_sep_ip_list": "a.a.a.a/aa, b.b.b.b/bb",
		},
		NoColor: true,
	}
	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)
	actualExampleList := terraform.OutputList(t, terraformOptions, "ips_as_list")
	assert.Equal(t, expectedList, actualExampleList)
}

func TestPreservesTailList(t *testing.T) {
	expectedList := []string{"a.a.a.a/aa", "b.b.b.b/bb", "c.c.c.c/cc"}
	terraformOptions := &terraform.Options{
		TerraformDir: "../..",
		Vars: map[string]interface{}{
			"comma_sep_ip_list": "a.a.a.a/aa, b.b.b.b/bb",
			"tail_list":         []string{"c.c.c.c/cc"},
		},
		NoColor: true,
	}
	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)
	actualExampleList := terraform.OutputList(t, terraformOptions, "ips_as_list")
	assert.Equal(t, expectedList, actualExampleList)
}

func TestBlankInputIsEmptyList(t *testing.T) {
	expectedList := []string{}
	terraformOptions := &terraform.Options{
		TerraformDir: "../..",
		Vars: map[string]interface{}{
			"comma_sep_ip_list": "",
		},
		NoColor: true,
	}
	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)
	actualExampleList := terraform.OutputList(t, terraformOptions, "ips_as_list")
	assert.Equal(t, expectedList, actualExampleList)
}
