// Build a script to format and run tests of a Terraform module project
package main

import (
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"strings"

	"github.com/magefile/mage/mg"
	"github.com/magefile/mage/sh"
)

// The default target when the command executes `mage` in Cloud Shell
var Default = RunAllTargets

func main() {
	Default()
}

// A build step that runs Clean, Format, Unit and Integration in sequence
func RunAllTargets() {
	mg.Deps(CleanAll)
	mg.Deps(LintCheckGo)
	mg.Deps(LintCheckTerraform)
	mg.Deps(RunUnitTests)
	mg.Deps(RunIntegrationTests)
}

// A build step that runs unit tests
func RunUnitTests() error {
	fmt.Println("INFO: Running unit tests...")
	return FindAndRunTests("unit")
}

// A build step that runs integration tests
func RunIntegrationTests() error {
	fmt.Println("INFO: Running integration tests...")
	return FindAndRunTests("integration")
}

// finds all tests with a given path suffix and runs them using `go test`
func FindAndRunTests(path_suffix string) error {
	goModules, err := sh.Output("go", "list", "./...")
	if err != nil {
		return err
	}

	testTargetModules := make([]string, 0)
	for _, module := range strings.Fields(goModules) {
		if strings.HasSuffix(module, path_suffix) {
			testTargetModules = append(testTargetModules, module)
		}
	}

	if len(testTargetModules) == 0 {
		return errors.New(fmt.Sprintf("No modules found for testing prefix '%s'", path_suffix))
	}

	cmd_args := []string{"test"}
	cmd_args = append(cmd_args, testTargetModules...)
	cmd_args = append(cmd_args, "-v", "-timeout", "7200s")
	return sh.RunV("go", cmd_args...)
}

// A build step that fails if go code is not formatted properly
func LintCheckGo() error {
	fmt.Println("INFO: Checking format for Go files...")
	return VerifyRunsQuietly("go", "fmt", "./...")
}

// a build step that fails if terraform files are not formatted properly
func LintCheckTerraform() error {
	fmt.Println("INFO: Checking format for Terraform files...")
	return VerifyRunsQuietly("terraform", "fmt")
}

// runs a command and ensures that the exit code indicates success and that there is no output to stdout
func VerifyRunsQuietly(cmd string, args ...string) error {
	output, err := sh.Output(cmd, args...)

	if err != nil {
		return err
	}

	if len(output) == 0 {
		return nil
	}

	return errors.New(fmt.Sprintf("ERROR: command '%s' with arguments %s failed. Output was: '%s'", cmd, args, output))
}

// A build step that removes temporary build and test files
func CleanAll() error {
	fmt.Println("INFO: Cleaning...")
	return filepath.Walk(".", func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}
		if info.IsDir() && info.Name() == "vendor" {
			return filepath.SkipDir
		}
		if info.IsDir() && info.Name() == ".terraform" {
			os.RemoveAll(path)
			fmt.Printf("Removed \"%v\"\n", path)
			return filepath.SkipDir
		}
		if !info.IsDir() && (info.Name() == "terraform.tfstate" ||
			info.Name() == "terraform.tfplan" ||
			info.Name() == "terraform.tfstate.backup") {
			os.Remove(path)
			fmt.Printf("Removed \"%v\"\n", path)
		}
		return nil
	})
}
