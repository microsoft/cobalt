package test

import (
	"encoding/json"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/random"
)

// these are useful values used in many test
var region = "southcentralus"
var prefix = "smpl" + strings.ToLower(random.UniqueId())
var workspace = "smpl-" + strings.ToLower(random.UniqueId())

// helper function to parse blocks of JSON into a generic Go map
func asMap(t *testing.T, jsonString string) map[string]interface{} {
	var theMap map[string]interface{}
	if err := json.Unmarshal([]byte(jsonString), &theMap); err != nil {
		t.Fatal(err)
	}
	return theMap
}
