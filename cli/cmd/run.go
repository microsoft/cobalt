package cmd

import (
	"fmt"

	"github.com/spf13/cobra"
)

var (
	docker bool
)

var runCmd = &cobra.Command{
	Use:   "run",
	Short: "Run local test harness",
	Long:  `Run local test harness`,
	Run: func(cmd *cobra.Command, args []string) {
		if docker {
			fmt.Println("cobalt run --docker")
		} else {
			fmt.Println("cobalt run")
		}
	},
}

func init() {
	rootCmd.AddCommand(runCmd)
	runCmd.Flags().BoolVarP(&docker, "docker", "d", true, "Run test harness in local docker")
}
