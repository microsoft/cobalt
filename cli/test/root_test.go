package test

import (
	"testing"

	"github.com/Microsoft/cobalt/cli/cmd"
)

func TestSum(t *testing.T) {
	expected := 2
	actual := cmd.Sum(1, 1)

	if actual != expected {
		t.Errorf("Expected the sum to be %d but instead got %d!", expected, actual)
	}
}
