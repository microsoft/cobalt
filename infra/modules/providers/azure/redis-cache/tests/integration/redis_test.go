package integration

import (
	"fmt"
	"testing"

	"github.com/microsoft/cobalt/infra/modules/providers/azure/redis-cache/tests"
	"github.com/microsoft/cobalt/test-harness/infratests"
)

func TestRedisDeployment(t *testing.T) {
	if tests.RedisName == "" {
		t.Fatal(fmt.Errorf("tests.RedisName was not specified. Are all the required environment variables set?"))
	}

	if tests.ResourceGroupName == "" {
		t.Fatal(fmt.Errorf("tests.ResourceGroupName was not specified. Are all the required environment variables set?"))
	}

	testFixture := infratests.IntegrationTestFixture{
		GoTest:                t,
		TfOptions:             tests.RedisOptions,
		ExpectedTfOutputCount: 6,
		TfOutputAssertions: []infratests.TerraformOutputValidation{
			InspectProvisionedCache("name", "resource_group_name"),
			CheckRedisWriteOperations("hostname", "primary_access_key", "ssl_port"),
		},
	}
	infratests.RunIntegrationTests(&testFixture)
}
