package azure

import (
	"github.com/gruntwork-io/terratest/modules/shell"
	"os"
	"testing"
)

// CliServicePrincipalLoginE - Log into the local Azure CLI instance
func CliServicePrincipalLoginE(t *testing.T) error {
	return shell.RunCommandE(t, shell.Command{
		Command: "az",
		Args: []string{
			"login", "--service-principal",
			"-u", os.Getenv("ARM_CLIENT_ID"),
			"-p", os.Getenv("ARM_CLIENT_SECRET"),
			"--tenant", os.Getenv("ARM_TENANT_ID"),
		},
	})
}

// CliServicePrincipalLogin - Like CliServicePrincipalLoginE but fails in the case an error is returned
func CliServicePrincipalLogin(t *testing.T) {
	err := CliServicePrincipalLoginE(t)
	if err != nil {
		t.Fatal(err)
	}
}
