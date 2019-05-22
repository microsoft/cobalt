package cmd

import (
	"fmt"

	"github.com/spf13/cobra"
)

var (
	template string
)

var setupCmd = &cobra.Command{
	Use:   "setup",
	Short: "Setup a new project",
	Long:  `Setup command is used to create a project with templates`,
	Run: func(cmd *cobra.Command, args []string) {
		if len(template) > 0 {
			fmt.Printf("cobalt setup --template is %s\n", template)
		}
	},
}

func init() {
	rootCmd.AddCommand(setupCmd)
	setupCmd.Flags().StringVarP(&template, "template", "t", "", "Template name. Example: \"bedrock/azure-simple\"")
}
