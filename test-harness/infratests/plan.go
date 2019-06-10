/*
Package infratests this file provides a model for the JSON representation of a terraform plan. It describes
a minimal set of metadata produced by the plan and can be expanded to support other attributes
if needed
*/
package infratests

// TerraformPlan a JSON schema for the output of `terraform plan <planfile>`
type TerraformPlan struct {
	ResourceChanges []struct {
		Address string `json:"address"`
		Change  struct {
			Actions []string               `json:"actions"`
			After   map[string]interface{} `json:"after"`
		} `json:"change"`
	} `json:"resource_changes"`
}
