# Resource Deployment Testing in Cobalt

## Summary

This section describes how to build integration and validation tests for your cobalt deployment environments using docker and the terratest modules.

Terratest is a Go library that makes it easier to write automated tests for your infrastructure code. It provides a variety of helper functions and patterns for common infrastructure testing tasks.

In addition, the cobalt test suite allows for better collaboration with embedding into CI/CD tools such as Travis or Azure DevOps Pipelines.

This test harness runs automated tests for only the deployment templates that have changed by comparing the changes in your git log versus upstream master.

## Test Setup Locally

### Local Environment Setup

- You'll need to define a `.env` file in the root of the project. You can use our environment template file to start. `cp .env.template .env`
- Provide values for the environment values in `.env` which are required to authenticate Terraform to provision resources within your subscription.

```shell
ARM_SUBSCRIPTION_ID="<az-service-principal-subscription-id>"
ARM_CLIENT_ID="<az-service-principal-client-id>"
ARM_CLIENT_SECRET="<az-service-principal-auth-secret>"
ARM_TENANT_ID="<az-service-principal-tenant>"
ARM_ACCESS_KEY="<remote-state-storage-account-primary-key>"
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

- `-g` | `--go_version`: Golang version specification. This argument drives the version of the `golang` stretch base image. **Defaults** to `1.11`.
- `-t` | `--tf_version`: Terraform version specification. This argument drives which terraform version release this image will use.. **Defaults** to `0.11.13`

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

- `-t` | `--template_name_override`: The template folder to include for the test harness run(i.e. -t "azure-simple-hw"). When set, the git log will be ignored. **Defaults** to the git log.
- `-c` | `--tf_state_container`: The storage container name responsible for tracking remote state for terraform deployments. **Defaults** to `cobaltfstate-remote-state-container`
- `-a` | `--tf_state_storage_acct`: The storage account name responsible for tracking remote state for terraform deployments. **Defaults** to `cobaltfstate`.
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
- Create your working directory within your `GOPATH`. For example my path for cobalt is:

    ```script
    $ echo $GOPATH
    C:\Users\erisch\go
    $ pwd
    /c/Users/erisch/go/src/cobalt
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

#### Local Run Script

Run the test runner by calling the below script from the project's root directory.

```script
./test-harness/local-run-wo-docker.sh
```

##### Script Arguments

- `-t` | `--template_name_override`: The template folder to include for the test harness run(i.e. -t "azure-simple-hw"). When set, the git log will be ignored. **Defaults** to the git log.
- `-c` | `--tf_state_container`: The storage container name responsible for tracking remote state for terraform deployments. **Defaults** to `cobaltfstate-remote-state-container`
- `-a` | `--tf_state_storage_acct`: The storage account name responsible for tracking remote state for terraform deployments. **Defaults** to `cobaltfstate`.