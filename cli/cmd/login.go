package cmd

import (
	"fmt"

	"github.com/spf13/cobra"
)

var (
	azure, aws bool = false, false
)

var loginCmd = &cobra.Command{
	Use:   "login",
	Short: "Login to cloud provider.",
	Long:  `Login to cloud providers like Azure, AWS, etc...`,
	Run: func(cmd *cobra.Command, args []string) {
		if azure {
			fmt.Println("cobalt login --azure or cobalt login -a")
		}

		if aws {
			fmt.Println("cobalt login --aws or cobalt login -w")
		}
	},
}

func init() {
	rootCmd.AddCommand(loginCmd)
	loginCmd.Flags().BoolVarP(&azure, "azure", "a", true, "Login to Azure")
	loginCmd.Flags().BoolVarP(&aws, "aws", "w", true, "Login to AWS")
}
