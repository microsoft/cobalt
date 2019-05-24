// Build a script to format and run tests of a Terraform module project
package main

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"

	"github.com/magefile/mage/mg"
	"github.com/magefile/mage/sh"
)

// Default The default target when the command executes `mage` in Cloud Shell
var Default = RunAllTargets

func main() {
	Default()
}

// RunAllTargets A build step that runs Clean, Format, Unit and Integration in sequence
func RunAllTargets() {
	mg.Deps(CleanAll)
	mg.Deps(LintCheckGo)
	mg.Deps(LintCheckTerraform)
	mg.Deps(RunUnitTests)
	mg.Deps(RunIntegrationTests)
}

// RunUnitTests A build step that runs unit tests
func RunUnitTests() error {
	fmt.Println("INFO: Running unit tests...")
	return FindAndRunTests("unit")
}

// RunIntegrationTests A build step that runs integration tests
func RunIntegrationTests() error {
	fmt.Println("INFO: Running integration tests...")
	return FindAndRunTests("integration")
}

// FindAndRunTests finds all tests with a given path suffix and runs them using `go test`
func FindAndRunTests(pathSuffix string) error {
	goModules, err := sh.Output("go", "list", "./...")
	if err != nil {
		return err
	}

	testTargetModules := make([]string, 0)
	for _, module := range strings.Fields(goModules) {
		if strings.HasSuffix(module, pathSuffix) {
			testTargetModules = append(testTargetModules, module)
		}
	}

	if len(testTargetModules) == 0 {
		return fmt.Errorf("No modules found for testing prefix '%s'", pathSuffix)
	}

	cmdArgs := []string{"test"}
	cmdArgs = append(cmdArgs, testTargetModules...)
	cmdArgs = append(cmdArgs, "-v", "-timeout", "7200s")
	return sh.RunV("go", cmdArgs...)
}

// LintCheckGo A build step that fails if go code is not formatted properly
func LintCheckGo() error {
	fmt.Println("INFO: Checking format for Go files...")
	return verifyRunsQuietly("go", "fmt", "./...")
}

// LintCheckTerraform a build step that fails if terraform files are not formatted properly
func LintCheckTerraform() error {
	fmt.Println("INFO: Checking format for Terraform files...")
	return verifyRunsQuietly("terraform", "fmt")
}

// runs a command and ensures that the exit code indicates success and that there is no output to stdout
func verifyRunsQuietly(cmd string, args ...string) error {
	output, err := sh.Output(cmd, args...)

	if err != nil {
		return err
	}

	if len(output) == 0 {
		return nil
	}

	return fmt.Errorf("ERROR: command '%s' with arguments %s failed. Output was: '%s'", cmd, args, output)
}

// CleanAll A build step that removes temporary build and test files
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
