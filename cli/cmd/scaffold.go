package cmd

import (
	"fmt"

	"github.com/spf13/cobra"
)

var (
	name, location string
)

var scafCmd = &cobra.Command{
	Use:   "scaffold",
	Short: "Scoffold out a new project",
	Long:  `Scoffold command is used to create a project with templates`,
	Run: func(cmd *cobra.Command, args []string) {
		if len(name) > 0 {
			fmt.Printf("cobalt scaffold --name is %s\n", name)
		}

		if len(location) > 0 {
			fmt.Printf("cobalt scaffold --location is %s\n", location)
		}
	},
}

func init() {
	rootCmd.AddCommand(scafCmd)
	scafCmd.Flags().StringVarP(&name, "name", "n", "", "Project name")
	scafCmd.Flags().StringVarP(&location, "location", "l", "", "Folder path example: ~/src")
}
