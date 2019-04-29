# Resource Deployment Testing in Cobalt

## Summary

This section describes how to build integration and validation tests for your cobalt deployment environments using docker and the terratest modules.

Terratest is a Go library that makes it easier to write automated tests for your infrastructure code. It provides a variety of helper functions and patterns for common infrastructure testing tasks.

In addition, the cobalt test suite allows for better collaboration with embedding into CI/CD tools such as Travis or Azure DevOps Pipelines.

This test harness runs automated tests for only the deployment templates that have changed by comparing the changes in your git log versus upstream master.

## Prerequisites
- [Docker](https://docs.docker.com/install/) 18.09 or later
- An Azure subscription
- A [service principal](https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal)
- An azure storage account for tracking terraform remote backend state. You can use our backend state setup [template]((/infra/templates/backend-state-setup/README.md)) to provision the storage resources.
- [git](https://www.atlassian.com/git/tutorials/install-git)

## Test Setup Locally

1. Local Environment Setup
    - You'll need to define a `.env` file in the root of the project. You can use our environment template file to start. `cp .env.template .env`
    - Provide values for the environment values in `.env` which are required to authenticate Terraform to provision resources within your subscription.

        ```shell
        ARM_SUBSCRIPTION_ID="<az-service-principal-subscription-id>"
        ARM_CLIENT_ID="<az-service-principal-client-id>"
        ARM_CLIENT_SECRET="<az-service-principal-auth-secret>"
        ARM_TENANT_ID="<az-service-principal-tenant>"
        ARM_ACCESS_KEY="<remote-state-storage-account-primary-key>"
        ```

2. Base Image - Our test harness uses a base docker image to pre-package dependencies like Terraform, Go, Azure CLI, Terratest vendor packages, etc.

    - **Optional Step** - Cobalt uses the public [msftcse](https://cloud.docker.com/u/msftcse/repository/docker/msftcse/terratest) base image by default. We also provide a utility script to generate a new base image.
    - Rebuilding a new base image is as simple as running

        ```script
        ./test-harness/build-base-image.sh -g "<go_version>" -t "<terraform_version>"
        ```

        Keep in mind that the terraform version should align with the version from the provider [module](/infra/modules/providers/azure/provider/main.tf#L6)
    - The base image will be tagged as

        ```script
        msftcse/cobalt-test-base:g${GO_VERSION}t${TERRAFORM_VERSION}
        ```

3. **Local Run** - Run the test runner by calling the below script from the project root directory.
    - Test Harness Script

        ```script
        ./test-harness/local-run.sh
        ```
