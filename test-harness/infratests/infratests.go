/*
Package `infratests` is intended to act as a testing harness that makes testing Terraform templates
easy and efficient. The goal of this package is to minimize the boiler plate code required to effectively
test terraform implementations.

The current implementation is focused only on unit tests but it will be expanded to harness integration tests
as well.
*/
package infratests

import (
	"errors"
	"fmt"
	"os"
	"path"
	"testing"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	terraformCore "github.com/hashicorp/terraform/terraform"
)

type ResourceAttributeValueMapping map[string]map[string]string
type TerraformPlanValidation func(goTest *testing.T, plan *terraformCore.Plan)

// Holds metadata required to execute a unit test against a test against a terraform template
type UnitTestFixture struct {
	GoTest                *testing.T         // Go test harness
	TfOptions             *terraform.Options // Terraform options
	ExpectedResourceCount int                // Expected # of resources that Terraform should create
	// map of maps specifying resource <--> attribute <--> attribute value mappings
	ExpectedResourceAttributeValues ResourceAttributeValueMapping
	PlanAssertions                  []TerraformPlanValidation // user-defined plan assertions
}

// Executes terraform lifecycle events and verifies the correctness of the resulting terraform.
// The following actions are coordinated:
//	- Run `terraform init`
//	- Create new terraform workspace. This helps prevent accidentally deleting resources
//	- Run `terraform plan`
//	- Validate terraform plan file.
func RunUnitTests(fixture *UnitTestFixture) {
	terraform.Init(fixture.GoTest, fixture.TfOptions)

	workspace_name := random.UniqueId()
	terraform.WorkspaceSelectOrNew(fixture.GoTest, fixture.TfOptions, workspace_name)
	defer terraform.RunTerraformCommand(fixture.GoTest, fixture.TfOptions, "workspace", "delete", workspace_name)
	defer terraform.WorkspaceSelectOrNew(fixture.GoTest, fixture.TfOptions, "default")

	tf_plan_file_path := random.UniqueId() + ".plan"
	terraform.RunTerraformCommand(
		fixture.GoTest,
		fixture.TfOptions,
		terraform.FormatArgs(fixture.TfOptions, "plan", "-input=false", "-out", tf_plan_file_path)...)
	defer os.Remove(tf_plan_file_path)

	validateTerraformPlanFile(fixture, tf_plan_file_path)
}

// Validates a terraform plan file based on the test fixture. The following validations are made:
//	- The plan is only creating resources, and the number of resources created should match the
//		parameters from the test fixture. The plan should only create resources because it should
//		be brand new infrastructure on each PR cycle.
//	- The resource <--> attribute <--> attribute value mappings match the parameters from the test fixture
//	- The plan passes any user-defined assertions
func validateTerraformPlanFile(fixture *UnitTestFixture, tf_plan_file_path string) {
	file, err := os.Open(path.Join(fixture.TfOptions.TerraformDir, tf_plan_file_path))
	if err != nil {
		fixture.GoTest.Fatal(err)
	}
	defer file.Close()

	plan, err := terraformCore.ReadPlan(file)
	if err != nil {
		fixture.GoTest.Fatal(err)
	}

	validatePlanCreateProperties(fixture, plan)
	validatePlanResourceKeyValues(fixture, plan)

	// run user-provided assertions
	if fixture.PlanAssertions != nil {
		for _, planAssertion := range fixture.PlanAssertions {
			planAssertion(fixture.GoTest, plan)
		}
	}
}

// Validates high level attributes of a terraform plan creat properties. This includes:
//	- The plan is not empty
//	- The plan contains the correct number of resources
//	- The plan is only creating resources
func validatePlanCreateProperties(fixture *UnitTestFixture, plan *terraformCore.Plan) {
	if plan.Diff.Empty() {
		fixture.GoTest.Fatal(errors.New("Plan diff was unexpectedly empty"))
	}

	// plans should contain diffs of type `DiffCreate` otherwise the test may accidentally remove resources
	for _, module := range plan.Diff.Modules {
		if module.ChangeType() != terraformCore.DiffCreate {
			fixture.GoTest.Fatal(errors.New(
				fmt.Sprintf("Plan unexpectedly contained an update of type '%s'", module.ChangeType())))
		}
	}

	resourceCount := 0
	for _, module := range plan.Diff.Modules {
		resourceCount += len(module.Resources)
	}

	// every plan should have the correct number of resources
	if resourceCount != fixture.ExpectedResourceCount {
		fixture.GoTest.Fatal(errors.New(fmt.Sprintf(
			"Plan unexpectedly had %d resources instead of %d", resourceCount, fixture.ExpectedResourceCount)))
	}
}

// validates that the resource <--> attribute <--> attribute value mappings match the parameters
// from the test fixture
func validatePlanResourceKeyValues(fixture *UnitTestFixture, plan *terraformCore.Plan) {
	// collect actual resource attrubte value mappings by iterating over the TF plan
	seen := ResourceAttributeValueMapping{}
	for _, module := range plan.Diff.Modules {
		for resource, resource_diffs := range module.Resources {
			seen[resource] = map[string]string{}
			for attribute, vals := range resource_diffs.Attributes {
				seen[resource][attribute] = vals.New
			}
		}
	}

	// verify that for each of the expected resource attribute value mappings that the expected
	// values are found in the terraform plan
	for resource, expected_attr_val_mappings := range fixture.ExpectedResourceAttributeValues {
		_, resource_found := seen[resource]
		if !resource_found {
			fixture.GoTest.Fatal(errors.New(fmt.Sprintf(
				"Plan unexpectedly did not contain a change for resource '%s'", resource)))
		}

		for expected_attr, expected_val := range expected_attr_val_mappings {
			actual_val, attr_found := seen[resource][expected_attr]
			if !attr_found {
				fixture.GoTest.Fatal(errors.New(fmt.Sprintf(
					"Plan unexpectedly did not contain a change for '%s.%s'", resource, expected_attr)))
			}

			if expected_val != actual_val {
				fixture.GoTest.Fatal(errors.New(fmt.Sprintf(
					"Plan unexpectedly had value '%s' instead of '%s' for '%s.%s'",
					actual_val,
					expected_val,
					resource,
					expected_attr,
				)))
			}
		}
	}
}
