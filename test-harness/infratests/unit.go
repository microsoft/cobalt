/*
This file provides abstractions that simplify the process of unit-testing terraform templates. The goal
is to minimize the boiler plate code required to effectively test terraform templates in order to reduce
the effort required to write robust template unit-tests.
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

// AttributeValueMapping Identifies mapping between attributes and values
type AttributeValueMapping map[string]string

// ResourceDescription Identifies mappings between resources and attributes
type ResourceDescription map[string]AttributeValueMapping

// TerraformPlanValidation A function that can run an assertion over a terraform plan
type TerraformPlanValidation func(goTest *testing.T, plan *terraformCore.Plan)

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

	tfPlanFilePath := random.UniqueId() + ".plan"
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
	file, err := os.Open(path.Join(fixture.TfOptions.TerraformDir, tfPlanFilePath))
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
			fixture.GoTest.Fatal(
				fmt.Errorf("Plan unexpectedly contained an update of type '%s'", string(module.ChangeType())))
		}
	}

	resourceCount := 0
	for _, module := range plan.Diff.Modules {
		resourceCount += len(module.Resources)
	}

	// every plan should have the correct number of resources
	if resourceCount != fixture.ExpectedResourceCount {
		fixture.GoTest.Fatal(fmt.Errorf(
			"Plan unexpectedly had %d resources instead of %d", resourceCount, fixture.ExpectedResourceCount))
	}
}

// validates that the resource <--> attribute <--> attribute value mappings match the parameters
// from the test fixture
func validatePlanResourceKeyValues(fixture *UnitTestFixture, plan *terraformCore.Plan) {
	// collect actual resource attrubte value mappings by iterating over the TF plan
	seen := ResourceDescription{}
	for _, module := range plan.Diff.Modules {
		for resource, resourceDiffs := range module.Resources {
			seen[resource] = AttributeValueMapping{}
			for attribute, vals := range resourceDiffs.Attributes {
				seen[resource][attribute] = vals.New
			}
		}
	}

	// verify that for each of the expected resource attribute value mappings that the expected
	// values are found in the terraform plan
	for resource, expectedMappings := range fixture.ExpectedResourceAttributeValues {
		_, resourceFound := seen[resource]
		if !resourceFound {
			fixture.GoTest.Fatal(fmt.Errorf(
				"Plan unexpectedly did not contain a change for resource '%s'", resource))
		}

		for expectedAttr, expectedVal := range expectedMappings {
			actualVal, attrFound := seen[resource][expectedAttr]
			if !attrFound {
				fixture.GoTest.Fatal(fmt.Errorf(
					"Plan unexpectedly did not contain a change for '%s.%s'", resource, expectedAttr))
			}

			if expectedVal != actualVal {
				fixture.GoTest.Fatal(fmt.Errorf(
					"Plan unexpectedly had value '%s' instead of '%s' for '%s.%s'",
					actualVal,
					expectedVal,
					resource,
					expectedAttr,
				))
			}
		}
	}
}
