package cmd

import (
	"fmt"
	"os"

	"github.com/mitchellh/go-homedir"
	"github.com/spf13/cobra"
	"github.com/spf13/viper"
)

const (
	cfgFileName string = ".cobalt"
)

var (
	cfgFile string
)

var rootCmd = &cobra.Command{
	Use:   "cobalt",
	Short: "Cobalt is an opinionated tool for configuring cloud providers with terraform templates.",
	Long: `

	_________     ______        __________ 
	__  ____/________  /_______ ___  /_  /_
	_  /    _  __ \_  __ \  __ '/_  /_  __/
	/ /___  / /_/ /  /_/ / /_/ /_  / / /_  
	\____/  \____//_.___/\__,_/ /_/  \__/  
										   	
                                                  
This project is an attempt to combine and share best practices when building production 
ready cloud native managed service solutions. Cobalt's infrastructure turn-key starter 
templates are based on real world engagements with enterprise customers.`,
	Run: func(cmd *cobra.Command, args []string) {
		// Do Stuff Here
	},
}

func Execute() {
	if err := rootCmd.Execute(); err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}

func init() {
	cobra.OnInitialize(initConfig)
	rootCmd.PersistentFlags().StringVar(&cfgFile, "config", "", "config file (default is $HOME/.cobalt)")
}

func initConfig() {
	// Don't forget to read config either from cfgFile or from home directory!
	if cfgFile != "" {
		// Use config file from the flag.
		viper.SetConfigFile(cfgFile)
	} else {
		// Find home directory.
		home, err := homedir.Dir()
		if err != nil {
			fmt.Println(err)
			os.Exit(1)
		}

		// Search config in home directory with name ".cobalt" (without extension).
		viper.AddConfigPath(home)
		viper.SetConfigName(cfgFileName)
	}

	if err := viper.ReadInConfig(); err != nil {
		// fmt.Println("Can't read config:", err)
		// os.Exit(1)
	}
}

func Sum(a int, b int) int {
	c := a + b
	return c
}
