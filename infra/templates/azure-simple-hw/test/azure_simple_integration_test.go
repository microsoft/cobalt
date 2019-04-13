package test

import (
	"fmt"
	"os"
	"path"
	"strings"
	"testing"
	"time"

	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
	random "github.com/gruntwork-io/terratest/modules/random"
	terraform "github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	terraformCore "github.com/hashicorp/terraform/terraform"
)

func configureTerraformOptions(t *testing.T, fixtureFolder string) *terraform.Options {
	location := os.Getenv("DATACENTER_LOCATION")
	//Generate unique azure resources to minimize feature conflicts across an engineering crew. ie cobalt-Geqw4K-appservice, cobalt-Geqw4K-resources
	prefix := fmt.Sprintf("cobalt-%s", random.UniqueId())
	tfstate_storage_account := os.Getenv("TF_STATE_STORAGE_ACCT")
	tf_state_container := os.Getenv("TF_STATE_CONTAINER")
	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: fixtureFolder,
		Upgrade:      true,
		Vars: map[string]interface{}{
			"prefix":   prefix,
			"location": location,
		},
		BackendConfig: map[string]interface{}{
			"storage_account_name": tfstate_storage_account,
			"container_name":       tf_state_container,
		},
	}

	return terraformOptions
}

func validatePlan(t *testing.T, tfPlanOutput string, tfOptions *terraform.Options) {
	terraform.RunTerraformCommand(t, tfOptions, terraform.FormatArgs(tfOptions, "plan", "-out="+tfPlanOutput)...)

	// Read and parse the plan output
	f, err := os.Open(path.Join(tfOptions.TerraformDir, tfPlanOutput))
	if err != nil {
		fmt.Printf("ERROR: plan parsing error message: %v\n", err)
		t.Fatal(err)
	}
	defer f.Close()
	plan, err := terraformCore.ReadPlan(f)
	if err != nil {
		fmt.Printf("ERROR: plan output message: %v\n", err)
		t.Fatal(err)
	}

	for _, mod := range plan.Diff.Modules {
		if len(mod.Path) == 1 && mod.Path[0] == "root" {
			expected := os.Getenv("DATACENTER_LOCATION")
			actual := mod.Resources["azurerm_app_service.main"].Attributes["location"].New
			if actual != expected {
				t.Fatalf("ERROR: Expect %v, but found %v", expected, actual)
			}
		}
	}
}

func TestITAzureSimple(t *testing.T) {
	t.Parallel()
	fixtureFolder := "../"
	terraformOptions := configureTerraformOptions(t, fixtureFolder)
	defer terraform.Destroy(t, terraformOptions)

	test_structure.RunTestStage(t, "init", func() {
		terraform.Init(t, terraformOptions)
	})

	test_structure.RunTestStage(t, "validate-plan", func() {
		tfPlanOutput := "terraform.tfplan"
		validatePlan(t, tfPlanOutput, terraformOptions)
	})

	test_structure.RunTestStage(t, "apply", func() {
		terraform.Apply(t, terraformOptions)
	})

	// Check whether the length of output meets the requirement. In public case, we check whether there occurs a public IP.
	test_structure.RunTestStage(t, "validate-e2e", func() {
		hostname := terraform.Output(t, terraformOptions, "app_service_default_hostname")

		// Validate the provisioned webpage container
		// It can take several minutes or so for the app to be deployed, so retry a few times
		maxRetries := 60
		timeBetweenRetries := 4 * time.Second

		http_helper.HttpGetWithRetryWithCustomValidationE(t, hostname, maxRetries, timeBetweenRetries, func(status int, content string) bool {
			return status == 200 && strings.Contains(content, "Hello App Service!")
		})
	})
}
