package integration

import (
	"github.com/stretchr/testify/require"
	"sort"
	"strings"
	"testing"
)

// Verifies that lists are equal, ignoring ordering and casing
func requireEqualIgnoringOrderAndCase(goTest *testing.T, first []string, second []string) {
	lowerCaseAndSort := func(values []string) []string {
		result := make([]string, len(values))
		for i, value := range values {
			result[i] = strings.ToLower(value)
		}

		sort.Strings(result)
		return result
	}

	require.Equal(goTest, lowerCaseAndSort(first), lowerCaseAndSort(second))
}
