// Build a script to format and run tests of a Terraform module project
package main

import (
	"fmt"
	"os"
	"path/filepath"

	"github.com/magefile/mage/mg"
	"github.com/magefile/mage/sh"
)

// The default target when the command executes `mage` in Cloud Shell
var Default = Full

func main() {
	Default()
}

// A build step that runs Clean, Format, Unit and Integration in sequence
func Full() {
	mg.Deps(Unit)
	mg.Deps(Integration)
}

// A build step that runs unit tests
func Unit() error {
	mg.Deps(Clean)
	mg.Deps(Format)
	fmt.Println("INFO: Running unit tests...")
	return sh.RunV("go", "test", "./...", "-run", "TestUT", "-v")
}

// A build step that runs integration tests
func Integration() error {
	mg.Deps(Clean)
	mg.Deps(Format)
	fmt.Println("INFO: Running integration tests...")
	return sh.RunV("go", "test", "./...", "-run", "TestIT", "-v", "-timeout", "99999s")
}

// A build step that formats both Terraform code and Go code
func Format() error {
	fmt.Println("INFO: Formatting...")
	return sh.RunV("go", "fmt", "./...")
}

// A build step that removes temporary build and test files
func Clean() error {
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
