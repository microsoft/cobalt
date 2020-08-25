package tests

import (
	"os"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

// appGatewayName the name of the application gateway
var appGatewayName = os.Getenv("APP_GATEWAY_NAME")

var AppGatewayOptions = &terraform.Options{
	TerraformDir: "../../",
	Upgrade:      true,
	Vars: map[string]interface{}{
		"name": appGatewayName,
	},
}
