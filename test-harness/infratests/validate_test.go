package infratests

import (
	"encoding/json"
	"testing"
)

var tests = []struct {
	dataSourceJSON    string
	searchTargetsJSON string
	shouldPass        bool
}{
	{
		`{"key1":[{"key2" : "foo"}, {"key2" : "bar"}]}`,
		`{"key1":[{"key2" : "foo"}, {"key2" : "bar"}]}`,
		true,
	}, {
		`{"key1":[{"key2" : "foo"}, {"key2" : "bar"}]}`,
		`{"key1":[{"key2" : "foo"}]}`,
		true,
	}, {
		`{"key1":[{"key2" : "foo"}, {"key2" : "bar"}]}`,
		`{"key1":[]}`,
		true,
	}, {
		`{"key1":{"key2": "foo", "key3": "bar"}}`,
		`{"key1":{"key3": "bar"}}`,
		true,
	}, {
		`{"key1":[{"key2" : "foo"}, {"key2" : "bar"}]}`,
		`{}`,
		true,
	}, {
		`{"key1":{"key2": "foo", "key3": "bar"}}`,
		`{"key1":[]}`,
		false, // key has wrong type
	}, {
		`{"key1":{"key2": "foo", "key3": "bar"}}`,
		`{"key1":{"key4": "foo"}}`,
		false, // key does not exist in data source
	}, {
		`{"key1":{"key2": "foo", "key3": "bar"}}`,
		`{"key1":{"key2": "bar"}}`,
		false, // key has wrong value
	}, {
		`{"key1":[1, 2, 3]}`,
		`{"key1":[4]}`,
		false, // list value does not exist in parent
	}, {
		`{"key1":[{"key2": "foo"}]}`,
		`{"key1":[{"key3": "foo"}]}`,
		false, // list value does not exist in parent
	}, {
		`{"key1":[{"key2": "foo"}]}`,
		`{"key1":[{"key2": "bar"}]}`,
		false, // list value does not exist in parent
	},
}

func TestVerifyTargets(t *testing.T) {
	for _, test := range tests {
		err := verifyTargetsExistInMap(
			jsonToMap(t, test.dataSourceJSON),
			jsonToMap(t, test.searchTargetsJSON))

		// the test should pass but there was an error
		if test.shouldPass && err != nil {
			t.Errorf("Search Targets `%s` were unexpectedly not found in Data Source `%s`. %s",
				test.searchTargetsJSON,
				test.dataSourceJSON,
				err)
		}

		// the test should not pass but there was no error
		if !test.shouldPass && err == nil {
			t.Errorf("Search Targets `%s` were unexpectedly found in Data Source `%s`",
				test.searchTargetsJSON,
				test.dataSourceJSON)
		}
	}
}

func jsonToMap(t *testing.T, jsonStr string) map[string]interface{} {
	var theMap map[string]interface{}
	if err := json.Unmarshal([]byte(jsonStr), &theMap); err != nil {
		t.Errorf("Unable to parse JSON `%s`. Error = `%s`", jsonStr, err)
	}
	return theMap
}
