# Resource Deployment Testing in Cobalt

## Summary

This section describes how to build integration and validation tests for your cobalt deployment environments using docker and the terratest modules.

Terratest is a Go library that makes it easier to write automated tests for your infrastructure code. It provides a variety of helper functions and patterns for common infrastructure testing tasks.

In addition, the cobalt test suite allows for better collaboration with embedding into CI/CD tools such as Travis or Azure DevOps Pipelines.

This test harness runs automated tests for only the deployment templates that have changed by comparing the changes in your git log versus upstream master.

## Writing tests against Terraform

This module includes a library that simplifies writing unit and integration [Note: integration test support is *pending*] tests against templates. It aims to extract out the most painful pieces of this process and provide common-sense implementations that can be shared across any template. Care is taken to provide hooks for more in-depth testing if it is needed by the template maintainer.

### Sample Unit Test Usage

The below example shows how easy it is to write a unit test that automatically coordinates the following:

- Run `terraform init`, `terraform workspace select`, `terraform plan` and parse the plan output into a [Terraform Plan](https://github.com/hashicorp/terraform/blob/master/terraform/plan.go)
- Validate that running the test would only create and not update/delete resources. (Note: This should always be true, otherwise the test is not running in isolation. Not running the test in isolation can be very dangerous and may cause resources to be deleted)
- Validate that the resource <--> attribute <--> attribute value mappings match those supplied via the `ExpectedResourceAttributeValues` parameter. This only asserts that the supplied mappings exist and match the terraform plan. If there are more resources or attributes, the test will not fail.
- Validate that the correct number of resources are created

Also note that the harness provides a hook that allows a list of user-defined functions that accept a handle to the GoTest and Terraform Plan objects. Users can supply custom test logic via this hook by supplying a non-nil `PlanAssertions` argument to `infratests.UnitTestFixture`. This feature is not used in the example below.

```go
package test

import (
    "fmt"
    "os"
    "testing"

    "github.com/gruntwork-io/terratest/modules/random"
    "github.com/gruntwork-io/terratest/modules/terraform"
    "github.com/microsoft/cobalt/test-harness/infratests"
)

var prefix = fmt.Sprintf("cobalt-%s", random.UniqueId())
var datacenter = os.Getenv("DATACENTER_LOCATION")

var tf_options = &terraform.Options{
    TerraformDir: "../../",
    Upgrade:      true,
    Vars: map[string]interface{}{
        "prefix":   prefix,
        "location": datacenter,
    },
}

func TestAzureSimple(t *testing.T) {
    test_fixture := infratests.UnitTestFixture{
        GoTest:                t,
        TfOptions:             tf_options,
        ExpectedResourceCount: 3,
        PlanAssertions:        nil,
        ExpectedResourceAttributeValues: infratests.ResourceAttributeValueMapping{
            "azurerm_app_service.main": map[string]string{
                "resource_group_name":            prefix,
                "location":                       datacenter,
                "site_config.0.linux_fx_version": "DOCKER|appsvcsample/static-site:latest",
            },
            "azurerm_app_service_plan.main": map[string]string{
                "kind":       "Linux",
                "location":   datacenter,
                "reserved":   "true",
                "sku.0.size": "S1",
                "sku.0.tier": "Standard",
            },
            "azurerm_resource_group.main": map[string]string{
                "location": datacenter,
                "name":     prefix,
            },
        },
    }

    infratests.RunUnitTests(&test_fixture)
}
```

### Sample Integration Testing Usage

The below example shows how easy it is to write an integration test that automatically coordinates the following:

- Run `terraform init`, `terraform workspace select`, `terraform apply` and parse the template outputs into a Go struct
- Validate that the terraform outputs are correct by asserting that the correct number exist and that any user-supplied key-value mappings are reflected in that output.
- Pass terraform output to user-defined test functions for use-case specific tests. In this case, we simply validate that the application endpoint responds as expected

```go
package test

import (
    "fmt"
    "os"
    "strings"
    "testing"
    "time"

    httpClient "github.com/gruntwork-io/terratest/modules/http-helper"
    "github.com/gruntwork-io/terratest/modules/random"
    "github.com/gruntwork-io/terratest/modules/terraform"
    "github.com/microsoft/cobalt/test-harness/infratests"
)

var prefix = fmt.Sprintf("cobalt-%s", random.UniqueId())
var datacenter = os.Getenv("DATACENTER_LOCATION")

var tfOptions = &terraform.Options{
    TerraformDir: "../../",
    Upgrade:      true,
    Vars: map[string]interface{}{
        "prefix":   prefix,
        "location": datacenter,
    },
    BackendConfig: map[string]interface{}{
        "storage_account_name": os.Getenv("TF_VAR_remote_state_account"),
        "container_name":       os.Getenv("TF_VAR_remote_state_container"),
    },
}

// Validates that the service responds with HTTP 200 status code. A retry strategy
// is used because it may take some time for the application to finish standing up.
func httpGetRespondsWith200(goTest *testing.T, output infratests.TerraformOutput) {
    hostname := output["app_service_default_hostname"].(string)
    maxRetries := 20
    timeBetweenRetries := 2 * time.Second

    httpClient.HttpGetWithRetryWithCustomValidationE(
        goTest,
        hostname,
        maxRetries,
        timeBetweenRetries,
        func(status int, content string) bool {
            return status == 200 && strings.Contains(content, "Hello App Service!")
        },
    )
}

func TestAzureSimple(t *testing.T) {
    testFixture := infratests.IntegrationTestFixture{
        GoTest:                t,
        TfOptions:             tfOptions,
        ExpectedTfOutputCount: 2,
        ExpectedTfOutput: infratests.TerraformOutput{
            "app_service_name":             fmt.Sprintf("%s-appservice", prefix),
            "app_service_default_hostname": strings.ToLower(fmt.Sprintf("https://%s-appservice.azurewebsites.net", prefix)),
        },
        TfOutputAssertions: []infratests.TerraformOutputValidation{
            httpGetRespondsWith200,
        },
    }
    infratests.RunIntegrationTests(&testFixture)
}
```

## Test Setup Locally

### Local Environment Setup

- You'll need to define a `.env` file in the root of the project. You can use our environment template file to start. `cp .env.template .env`
- Provide values for the environment values in `.env` which are required to authenticate Terraform to provision resources within your subscription.

```bash
ARM_SUBSCRIPTION_ID="<az-service-principal-subscription-id>"
ARM_CLIENT_ID="<az-service-principal-client-id>"
ARM_CLIENT_SECRET="<az-service-principal-auth-secret>"
ARM_TENANT_ID="<az-service-principal-tenant>"
ARM_ACCESS_KEY="<remote-state-storage-account-primary-key>"
TF_VAR_remote_state_account="<tf-remote-state-storage-account-name>"
TF_VAR_remote_state_container="<tf-remote-state-storage-container-name>"
```

## Local Test Runner Options

### Option 1: Docker

The benefit with running the test harness through docker is that developers don't need to worry about setting up their local environment. We strongly recommend running `local-run.sh` before submitting a PR as our devops pipeline runs the dockerized version of the test harness.

#### Prerequisites

- [Docker](https://docs.docker.com/install/) 18.09 or later
- An Azure subscription
- A [service principal](https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal)
- An azure storage account for tracking terraform remote backend state. You can use our backend state setup [template](../infra/templates/backend-state-setup/README.md) to provision the storage resources.
- [git](https://www.atlassian.com/git/tutorials/install-git)

#### Base Image Setup

Our test harness uses a base docker image to pre-package dependencies like Terraform, Go, Azure CLI, Terratest vendor packages, etc.

- **Optional Step** - Cobalt uses the public [msftcse/cobalt-test-base](https://hub.docker.com/r/msftcse/cobalt-test-base) base image by default. We also provide a utility script to generate a new base image.
- Rebuilding a new base image is as simple as running

```script
./test-harness/build-base-image.sh -g "<go_version>" -t "<terraform_version>"
```

##### Script Arguments

- `-g` | `--go_version`: Golang version specification. This argument drives the version of the `golang` stretch base image. **Defaults** to `1.12.5`.
- `-t` | `--tf_version`: Terraform version specification. This argument drives which terraform version release this image will use.. **Defaults** to `0.12.2`

Keep in mind that the terraform version should align with the version from the provider [module](/infra/modules/providers/azure/provider/main.tf#L6)

- The base image will be tagged as:

```script
msftcse/cobalt-test-base:g${GO_VERSION}t${TERRAFORM_VERSION}
```

#### Local Run Script

Run the test runner by calling the below script from the project's root directory. This is one of two options.

```script
./test-harness/local-run.sh
```

##### Script Arguments

- `-t` | `--template_name_override`: The template folder to include for the test harness run(i.e. -t "azure-hello-world"). When set, the git log will be ignored. **Defaults** to the git log.
- `-b` | `--docker_base_image_name`: The base image to use for the test harness continer. **Defaults** to `msftcse/cobalt-test-base:g${GO_VERSION}t${TF_VERSION}`.

### Option 2: Manual Setup

The benefit with setting up the test harness manually is that runtimes are quicker as we're not rebuilding the test harness image on each run.

The clear downside here is that you'll need to set up all cobalt base software packages and responsible for managing version dependency upgrades over time. Our central base image in docker hub is supported by CSE as well as version dependency upgrades.

The other downside is that you'll need to install this project within your `GOPATH` and pull down all `dep` vendor dependency packages.

#### Prerequisites

- An Azure subscription
- A [service principal](https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal)
- An azure storage account for tracking terraform remote backend state. You can use our backend state setup [template](../infra/templates/backend-state-setup/README.md) to provision the storage resources.
- [git](https://www.atlassian.com/git/tutorials/install-git)
- Follow [these instructions](https://golang.org/doc/install#download) to download the Go Distribution.
- Follow these [instructions](https://golang.org/doc/install#testing) to test your golang install.
- Ensure that your repository is checked out into the following directory that does not live inside `$GOPATH`. Example:

    ```script
    $ echo $GOPATH
    /home/workspace/go
    $ pwd
    /home/workspace/oss/cobalt
    ```

- Install [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
- Install golang's dep package manager via Git Bash.

    ```script
    curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh
    dep version
    dep:
        version     : v0.5.0
        build date  : 2018-07-26
        git hash    : 224a564
        go version  : go1.10.3
        go compiler : gc
        platform    : windows/amd64
        features    : ImportDuringSolve=false
    ```

- Install [Terraform](https://learn.hashicorp.com/terraform/getting-started/install.html)

#### Local Run Script (No-Docker Version)

Run the test runner by calling the below script from the project's root directory.

```script
./test-harness/local-run-wo-docker.sh
```

##### Script Arguments (No-Docker Version)

- `-t` | `--template_name_override`: The template folder to include for the test harness run(i.e. -t "azure-hello-world"). When set, the git log will be ignored. **Defaults** to the git log.
- `-c` | `--tf_state_container`: The storage container name responsible for tracking remote state for terraform deployments. **Defaults** to `cobaltfstate-remote-state-container`
- `-a` | `--tf_state_storage_acct`: The storage account name responsible for tracking remote state for terraform deployments. **Defaults** to `cobaltfstate`.