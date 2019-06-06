/*
This file provides abstractions that simplify the process of integration-testing terraform templates. The goal
is to minimize the boiler plate code required to effectively test terraform templates in order to reduce
the effort required to write robust template integration-tests.
*/
package infratests

import (
	"encoding/json"
	"fmt"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

// TerraformOutput Models terraform output key values
type TerraformOutput map[string]interface{}

// TerraformOutputValidation A function that can validate terraform output
type TerraformOutputValidation func(goTest *testing.T, output TerraformOutput)

// IntegrationTestFixture Holds metadata required to execute an integration test against a test against a terraform template
type IntegrationTestFixture struct {
	GoTest                *testing.T                  // Go test harness
	TfOptions             *terraform.Options          // Terraform options
	ExpectedTfOutputCount int                         // Expected # of resources that Terraform should create
	ExpectedTfOutput      TerraformOutput             // Expected Terraform Output
	TfOutputAssertions    []TerraformOutputValidation // user-defined plan assertions
	Workspace             string
}

// RunIntegrationTests Executes terraform lifecycle events and verifies the correctness of the resulting resources.
// The following actions are coordinated:
//	- Run `terraform init`
//	- Create new terraform workspace. This helps prevent accidentally deleting resources
//	- Run `terraform apply`
//	- Run `terraform output`
//	- Validate outputs
//	- Run user-supplied validation of outputs
//	- Destroy resources
func RunIntegrationTests(fixture *IntegrationTestFixture) {
	terraform.Init(fixture.GoTest, fixture.TfOptions)

	workspaceName := fixture.Workspace
	if workspaceName == "" {
		workspaceName = "default-int-testing"
	}

	terraform.WorkspaceSelectOrNew(fixture.GoTest, fixture.TfOptions, workspaceName)
	defer terraform.RunTerraformCommand(fixture.GoTest, fixture.TfOptions, "workspace", "delete", workspaceName)
	defer terraform.WorkspaceSelectOrNew(fixture.GoTest, fixture.TfOptions, "default")

	defer terraform.Destroy(fixture.GoTest, fixture.TfOptions)
	terraform.Apply(fixture.GoTest, fixture.TfOptions)

	output := terraform.OutputAll(fixture.GoTest, fixture.TfOptions)
	validateTerraformOutput(fixture, TerraformOutput(output))
}

// Coordinates the following validations of a terraform output:
//	- The output contains the correct number of items
//	- The output values match any user-supplied key-value mappings. This only validates
//	  that any user-supplied key-value mappings are correct, and will not fail if the
//	  output has more mappings
//	- The output has the correct number of items
//	- Run any user-supplied assertions over the output
func validateTerraformOutput(fixture *IntegrationTestFixture, output TerraformOutput) {
	validateTerraformOutputCount(fixture, output)
	validateTerraformOutputKeyValues(fixture, output)

	// run user-provided assertions over the TF output
	for _, outputAssertion := range fixture.TfOutputAssertions {
		outputAssertion(fixture.GoTest, output)
	}
}

// Validates that the terraform output contains the expected number of items
func validateTerraformOutputCount(fixture *IntegrationTestFixture, output TerraformOutput) {
	if len(output) != fixture.ExpectedTfOutputCount {
		fixture.GoTest.Fatal(fmt.Errorf(
			"Output unexpectedly had %d entries instead of %d",
			len(output),
			fixture.ExpectedTfOutputCount,
		))
	}
}

// Validates that any outputs that the user supplies match the actual terraform outputs.
// Note: the comparison is done by converting the expected and actual values into JSON and
// doing a string comparison. This solves a number of complexities, such as:
//	- Handles comparison of generic data types automatically
//	- Handles differences in key ordering for maps
//	- Handles all handling of generics, which is tricky in Go
func validateTerraformOutputKeyValues(fixture *IntegrationTestFixture, output TerraformOutput) {
	for expectedKey, expectedValue := range fixture.ExpectedTfOutput {
		actualValue, isFound := output[expectedKey]
		if !isFound {
			fixture.GoTest.Fatal(fmt.Errorf("Output unexpectedly did not contain key %s", expectedKey))
		}

		expectedAsJSON := jsonOrFail(fixture, expectedValue)
		actualAsJSON := jsonOrFail(fixture, actualValue)

		if expectedAsJSON != actualAsJSON {
			fixture.GoTest.Fatal(fmt.Errorf(
				"Output value for '%s' was expected to be '%s' but was '%s'",
				expectedKey,
				expectedAsJSON,
				actualAsJSON,
			))
		}
	}
}

// parse data to JSON or fail if an error was encountered
func jsonOrFail(fixture *IntegrationTestFixture, value interface{}) string {
	asJSON, err := json.Marshal(value)
	if err != nil {
		fixture.GoTest.Fatal(err)
	}
	return string(asJSON)
}
