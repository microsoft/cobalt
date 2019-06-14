/*
Package infratests This file provides abstractions that simplify the process of unit-testing terraform templates. The goal
is to minimize the boiler plate code required to effectively test terraform templates in order to reduce
the effort required to write robust template unit-tests.
*/
package infratests

import (
	"encoding/json"
	"errors"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"testing"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

// ResourceDescription Identifies mappings between resources and attributes
type ResourceDescription map[string]map[string]interface{}

// TerraformPlanValidation A function that can run an assertion over a terraform plan
type TerraformPlanValidation func(goTest *testing.T, plan TerraformPlan)

// UnitTestFixture Holds metadata required to execute a unit test against a test against a terraform template
type UnitTestFixture struct {
	GoTest                *testing.T         // Go test harness
	TfOptions             *terraform.Options // Terraform options
	Workspace             string
	ExpectedResourceCount int // Expected # of resources that Terraform should create
	// map of maps specifying resource <--> attribute <--> attribute value mappings
	ExpectedResourceAttributeValues ResourceDescription
	PlanAssertions                  []TerraformPlanValidation // user-defined plan assertions
}

// RunUnitTests Executes terraform lifecycle events and verifies the correctness of the resulting terraform.
// The following actions are coordinated:
//	- Run `terraform init`
//	- Create new terraform workspace. This helps prevent accidentally deleting resources
//	- Run `terraform plan`
//	- Validate terraform plan file.
func RunUnitTests(fixture *UnitTestFixture) {
	terraform.Init(fixture.GoTest, fixture.TfOptions)

	workspaceName := fixture.Workspace
	if workspaceName == "" {
		workspaceName = "default-unit-testing"
	}

	terraform.WorkspaceSelectOrNew(fixture.GoTest, fixture.TfOptions, workspaceName)
	defer terraform.RunTerraformCommand(fixture.GoTest, fixture.TfOptions, "workspace", "delete", workspaceName)
	defer terraform.WorkspaceSelectOrNew(fixture.GoTest, fixture.TfOptions, "default")

	tfPlanFilePath := filepath.FromSlash(fmt.Sprintf("%s/%s.plan", os.TempDir(), random.UniqueId()))
	terraform.RunTerraformCommand(
		fixture.GoTest,
		fixture.TfOptions,
		terraform.FormatArgs(fixture.TfOptions, "plan", "-input=false", "-out", tfPlanFilePath)...)
	defer os.Remove(tfPlanFilePath)

	validateTerraformPlanFile(fixture, tfPlanFilePath)
}

// Validates a terraform plan file based on the test fixture. The following validations are made:
//	- The plan is only creating resources, and the number of resources created should match the
//		parameters from the test fixture. The plan should only create resources because it should
//		be brand new infrastructure on each PR cycle.
//	- The resource <--> attribute <--> attribute value mappings match the parameters from the test fixture
//	- The plan passes any user-defined assertions
func validateTerraformPlanFile(fixture *UnitTestFixture, tfPlanFilePath string) {
	plan := parseTerraformPlan(fixture, tfPlanFilePath)
	validatePlanCreateProperties(fixture, plan)
	validatePlanResourceKeyValues(fixture, plan)

	// run user-provided assertions
	if fixture.PlanAssertions != nil {
		for _, planAssertion := range fixture.PlanAssertions {
			planAssertion(fixture.GoTest, plan)
		}
	}
}

func parseTerraformPlan(fixture *UnitTestFixture, filePath string) TerraformPlan {
	// Note: when the PR linked below is merged and the new build is used by this codebase,
	// we can leverage Terratest to run this for us. Currently with large plan outputs,
	// a buffer overflow will happen in Terratest because the default max character limit
	// may be exceeded for large plan files:
	//
	//	- Issue: https://github.com/gruntwork-io/terratest/issues/203
	//	- PR: https://github.com/gruntwork-io/terratest/pull/317
	//
	// jsonBytes := []bytes(terraform.RunTerraformCommand(
	//     fixture.GoTest,
	//     fixture.TfOptions,
	//     terraform.FormatArgs(&terraform.Options{}, "show", "-json", filePath)...))
	cmd := exec.Command("terraform", "show", "-json", filePath)
	cmd.Dir = fixture.TfOptions.TerraformDir
	jsonBytes, cmdErr := cmd.Output()
	if cmdErr != nil {
		fixture.GoTest.Fatal(cmdErr)
	}

	fmt.Println("Got terraform plan...", string(jsonBytes))
	var plan TerraformPlan
	jsonErr := json.Unmarshal(jsonBytes, &plan)
	if jsonErr != nil {
		fixture.GoTest.Fatal(jsonErr)
	}
	return plan
}

// Validates high level attributes of a terraform plan creat properties. This includes:
//	- The plan is not empty
//	- The plan contains the correct number of resources
//	- The plan is not executing any destructive actions
func validatePlanCreateProperties(fixture *UnitTestFixture, plan TerraformPlan) {
	if len(plan.ResourceChanges) == 0 {
		fixture.GoTest.Fatal(errors.New("Plan diff was unexpectedly empty"))
	}

	if len(plan.ResourceChanges) != fixture.ExpectedResourceCount {
		fixture.GoTest.Fatal(fmt.Errorf(
			"Plan unexpectedly had %d resources instead of %d", len(plan.ResourceChanges), fixture.ExpectedResourceCount))
	}

	// a unit test should never create a destructive action like deleting a resource
	allowedActions := map[string]bool{"create": true, "read": true}
	for _, resource := range plan.ResourceChanges {
		for _, action := range resource.Change.Actions {
			if !allowedActions[action] {
				fixture.GoTest.Fatal(
					fmt.Errorf("Plan unexpectedly actions other than `create`: %s", resource.Change.Actions))
			}
		}
	}
}

// verifies that the attribute value mappings for each resource specified by the client exist
// as a subset of the actual values defined in the terraform plan.
func validatePlanResourceKeyValues(fixture *UnitTestFixture, plan TerraformPlan) {
	theRealPlanAsMap := planToMap(plan)
	theExpectedPlanAsMap := resourceDescriptionToMap(fixture.ExpectedResourceAttributeValues)

	if err := verifyTargetsExistInMap(theRealPlanAsMap, theExpectedPlanAsMap); err != nil {
		fixture.GoTest.Fatal(err)
	}
}

// transforms the output of `terraform show -json <planfile>` into a generic map
func planToMap(plan TerraformPlan) map[string]interface{} {
	mp := make(map[string]interface{})
	for _, resource := range plan.ResourceChanges {
		mp[resource.Address] = resource.Change.After
	}
	return mp
}

// transforms a resource description into a generic map
func resourceDescriptionToMap(resources ResourceDescription) map[string]interface{} {
	mp := make(map[string]interface{})
	for key, value := range resources {
		mp[key] = value
	}
	return mp
}
