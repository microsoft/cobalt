package cmd

import (
	"fmt"

	"github.com/spf13/cobra"
)

var testHarnessCmd = &cobra.Command{
	Use:   "test-harness",
	Short: "Setup local test harness",
	Long:  `Setup local test harness`,
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println("cobalt test-harness")
	},
}

func init() {
	rootCmd.AddCommand(testHarnessCmd)
}
