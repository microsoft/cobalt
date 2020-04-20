package integration

import (
	"fmt"
	"strings"
	"testing"
	"time"

	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"

	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/microsoft/cobalt/test-harness/infratests"
	"github.com/stretchr/testify/require"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

func validateKeyvaultFlexVolNamespace(t *testing.T, kubeConfigFile string) {
	keyvaultNamespace := "kv"
	options := *k8s.NewKubectlOptions("", kubeConfigFile)
	options.Namespace = keyvaultNamespace
	expectedPodCount := 3
	k8s.WaitUntilNumPodsCreated(t, &options, metav1.ListOptions{}, expectedPodCount, 30, 10*time.Second)
}

func validateKeyvaultServicePrincipalSecret(t *testing.T, kubeConfigFile string, clientIDOutputName string, output infratests.TerraformOutput) {
	secretNamespace := "default"
	options := *k8s.NewKubectlOptions("", kubeConfigFile)
	spClientIDExpected := output[clientIDOutputName].(string)
	options.Namespace = secretNamespace

	secret := *k8s.GetSecret(t, &options, "kvcreds")
	spClientIDActual := string(secret.Data["clientid"])

	require.Equal(t, spClientIDExpected, spClientIDActual, "Expect Kubernetes kvcreds secret client id to match output")
}

func validateDeployedWebApp(t *testing.T, kubeConfigFile string, k8ServiceName string, expectedBodySubstring string) {
	webAppNamespace := "default"
	options := *k8s.NewKubectlOptions("", kubeConfigFile)
	options.Namespace = webAppNamespace
	k8s.WaitUntilServiceAvailable(t, &options, k8ServiceName, 30, 10*time.Second)

	service := k8s.GetService(t, &options, k8ServiceName)
	loadBalancerIP := service.Status.LoadBalancer.Ingress[0].IP
	hostname := fmt.Sprintf("http://%s:%d", loadBalancerIP, service.Spec.Ports[0].Port)
	maxRetries := 60
	timeBetweenRetries := 5 * time.Second

	_reqErr := http_helper.HttpGetWithRetryWithCustomValidationE(t, hostname, maxRetries, timeBetweenRetries, func(status int, body string) bool {
		return status == 200 && strings.Contains(body, expectedBodySubstring)
	})

	if _reqErr != nil {
		errorMsg := fmt.Sprintf("Error connecting to external load balancer: %s", hostname)
		t.Fatal(errorMsg)
	}
}

func validateFluxNamespace(t *testing.T, kubeConfigFile string) {
	fluxNamespace := "flux"
	fluxAppLabel := "flux"
	options := *k8s.NewKubectlOptions("", kubeConfigFile)
	options.Namespace = fluxNamespace
	expectedPodCount := 2
	filters := metav1.ListOptions{
		LabelSelector: fmt.Sprintf("app=%s", fluxAppLabel),
	}

	k8s.WaitUntilNumPodsCreated(t, &options, metav1.ListOptions{}, expectedPodCount, 30, 10*time.Second)

	pods := k8s.ListPods(t, &options, filters)
	for _, pod := range pods {
		k8s.WaitUntilPodAvailable(t, &options, pod.Name, 30, 10*time.Second)
	}
}

// BaselineClusterAssertions - Runs the suite of baseline tests to validate the cluster is fully functional
func BaselineClusterAssertions(kubeConfigFile string, clientIDOutputName string, k8ExternalServiceName string, expectedBodySubstring string) func(t *testing.T, output infratests.TerraformOutput) {
	return func(t *testing.T, output infratests.TerraformOutput) {
		t.Parallel()

		validateFluxNamespace(t, kubeConfigFile)
		validateKeyvaultFlexVolNamespace(t, kubeConfigFile)
		validateKeyvaultServicePrincipalSecret(t, kubeConfigFile, clientIDOutputName, output)
		validateDeployedWebApp(t, kubeConfigFile, k8ExternalServiceName, expectedBodySubstring)
	}
}
