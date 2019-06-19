/*
Package infratests This file provides validation utilities that can be used by the core testing constructs
*/
package infratests

import (
	"fmt"
	"reflect"
)

// This function validates that a set of search targets exist in a map. The intended use case is to allow
// a user of this library to provide a set of *expected values* that should exist within a larger set of
// *actual values.* In other words, this is a map equality check that does not care about ordering in keys/lists
// and will not fail if the *expected values* are a subset of the *actual values.*
//
// In the case that the *expected values* are found in the *actual values,* nil will be returned. Otherwise an
// error describing the mismatch will be returned.
//
// Some examples (in pseudo-code):
//	- Exact Match:
//		a := {"key1":[{"key2" : "foo"}, {"key2" : "bar"}]}
//		verifyTargetsExistInMap(a, a) --> nil
//
//	- Subset Match #1:
//		a := {"key1":[{"key2" : "foo"}, {"key2" : "bar"}]}
//		b := {"key1":[{"key2" : "foo"}]}
//		verifyTargetsExistInMap(a, b) --> nil
//
//	- Subset Match #2:
//		a := {"key1":[{"key2" : "foo"}, {"key2" : "bar"}]}
//		b := {"key1":[]}
//		verifyTargetsExistInMap(a, b) --> nil
//
//	- Subset Match #3:
//		a := {"key1":{"key2": "foo", "key3", "bar"}}
//		b := {"key1":{"key3", "bar"}}
//		verifyTargetsExistInMap(a, b) --> nil
//
//	- Mismatch #1:
//		a := {"key1":{"key2": "foo", "key3", "bar"}}
//		b := {"key1":[]}
//		verifyTargetsExistInMap(a, b) --> ERROR: wrong type for key `key1`
//
//	- Mismatch #2:
//		a := {"key1":{"key2": "foo", "key3", "bar"}}
//		b := {"key1":{"key4": "foo"}}
//		verifyTargetsExistInMap(a, b) --> ERROR: `key4` not found
//
//	- Mismatch #3:
//		a := {"key1":{"key2": "foo", "key3", "bar"}}
//		b := {"key1":{"key2": "bar"}}
//		verifyTargetsExistInMap(a, b) --> ERROR: wrong value for `key2`
//
// The algorithm used to do the equality check is to execute a DFS search in parallel for both maps. In the case
// that a mismatch (the values do not match, or the shape of the maps is different in a way that indicates a mismatch)
// is identified, the search will be terminated. If no mismatches are found then `nil` is returned
func verifyTargetsExistInMap(dataSource map[string]interface{}, searchTargets map[string]interface{}) error {
	for targetKey := range searchTargets {
		candidateMatch, candidateExists := dataSource[targetKey]
		target, targetExists := searchTargets[targetKey]

		// both maps should contain the target search key
		if !candidateExists || !targetExists {
			return fmt.Errorf("Unexpectedly could not find key '%s'", targetKey)
		}

		// the values for the key should be the same type
		if !isSameType(candidateMatch, target) {
			return fmt.Errorf("Unexpectedly found type '%T' instead of '%T'", candidateMatch, target)
		}

		// the key is found and both values are of the same type. time to look for a subset match
		switch typedTarget := target.(type) {
		case bool, float32, float64, int, string:
			if typedTarget != candidateMatch {
				return fmt.Errorf("Expected %s but got %s", typedTarget, candidateMatch)
			}
		case []interface{}:
			if err := verifyTargetsExistInList(candidateMatch.([]interface{}), typedTarget); err != nil {
				return err
			}
		case map[string]interface{}:
			if err := verifyTargetsExistInMap(candidateMatch.(map[string]interface{}), typedTarget); err != nil {
				return err
			}
		default:
			return fmt.Errorf("Comparison for type '%T' in a map not implemented", typedTarget)
		}

	}

	return nil
}

// This function has the same semantics as `verifyTargetsExistInMap` (so the documentation will not be repeated)
// except that it works for lists.
func verifyTargetsExistInList(dataSource []interface{}, searchTargets []interface{}) error {
	for _, target := range searchTargets {
		matchFound := false

		switch typedTarget := target.(type) {
		case bool, float32, float64, int, string:
			for _, candidateMatch := range dataSource {
				matchFound = matchFound || typedTarget == candidateMatch
			}
		case map[string]interface{}:
			for _, candidateMatch := range dataSource {
				if isSameType(candidateMatch, typedTarget) {
					err := verifyTargetsExistInMap(candidateMatch.(map[string]interface{}), typedTarget)
					matchFound = matchFound || err == nil
				}
			}
		default:
			return fmt.Errorf("Comparison for type '%T' in a list not yet implemented", typedTarget)
		}

		if !matchFound {
			return fmt.Errorf("Unexpectedly did not find '%s' in '%s'", target, dataSource)
		}
	}

	return nil
}

// return true if the values have the same type, false otherwise
func isSameType(a interface{}, b interface{}) bool {
	return reflect.TypeOf(a) == reflect.TypeOf(b)
}
