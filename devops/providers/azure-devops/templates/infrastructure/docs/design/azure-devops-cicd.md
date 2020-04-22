# Continuous Integration / Continuous Deployment Pipeline in Azure DevOps

v0.1 - 12/11/2019

## Introduction

It is highly desireable to have a fully-automated CI/CD system in place to assist with testing and validation of source code changes made to the application services and supporting infrastructure. Without such a system, it is difficult to have any degree of confidence that a new deployment will succeed without introducing new regressions.

This document outlines a solution which implements Unified YAML Pipelines in Azure DevOps to achieve the desired degree of automation.

Much of this design is based on learnings from the Microsoft Cobalt Infrastructure-As-Code project (see: [github.com/microsoft/cobalt](https://github.com/microsoft/cobalt "microsoft/cobalt on GitHub")). While some structural differences exist between Cobalt's CI/CD and this design, it should be reasonable to assume that much of that code from Cobalt can be repurposed here. Specifically, most of the scripts used for testing and build environment configuration should be able to be directly re-used, as well as much of the YAML template components.

## In Scope

- Document the key requirements for an automation pipeline
- Identify the desired pipeline structure
- Identify the individual components and workflow of the desired pipeline
- Document any (known) key implementation details that may support implementation of the pipeline
- Build/deployment of the common/shared infrastructure used to host the application-level services and components

## Out of scope

- Build/Deployment of the individual hosted application services and components
- Handling of any partial rollback scenarios for cases where a deployment failure might result in an indeterminate state  

## Key Terms

- **YAML**: Abbreviation for the “Yet Another Markup Language” file format
- **AzDO**: Abbreviation for “Azure DevOps”
- **PR**: Abbreviation for “Pull Request”
- **CI/CD**: Abbreviation for “Continuous Integration / Continuous Deployment”
- **WS**: Abbreviation for “Workspace”
- **TF**: Abbreviation for “Terraform”

## Key Requirements

- Design a CI/CD Pipeline to perform continuous verification and deployment of the infrastructure needed to support running the application's services on the Azure platform in a repeatable manner.
  - Implemented as a Unified Pipeline (YAML) for Azure DevOps
  - Support deployment of shared cloud resources (KeyVault, CosmosDB, etc), whether these are existing or new resources
  - Support deployment of application-hosting infrastructure (unpopulated App Services) that will eventually house the actual application service components
  - Capture basic metrics and telemetry from the deployment process for monitoring of ongoing pipeline performance and diagnosis of any deployment failures
  - Support deployment into multiple environments ('qa', 'dev', 'devint', 'prod', etc)
  - Execute automated unit-level and integration-level tests against the resources, prior to deployment into any long-living environments
  - Provide a manual approval process to gate deployment into long-living environments
  - Provide detection, abort, and reporting of deployment status when a failure occurs
  - Supports parallel deployments
    - Multiple CI/CD pipeline instances, not parallel tasks within a single instance
    - Needed for scenarios such as concurrent PRs and/or master merge triggered builds when an Agent Pool is configured with multiple Build Agents
  - Deployments should be idempotent

## Pipeline Structure

It is a good practice to decompose large YAML pipelines into smaller components that get referenced by a top-level orchestration. In particular, complex tasks (or inline script tasks) should be split out into their own xaml templates. In accordance with this, the CI/CD pipeline is decomposed into the following key workflow components:

### Pipeline Orchestration Files

| file | description |
|---|---|
| `pipeline.yml` | Main pipeline definition, registered with AzDO |
| `pipeline-stage-compose.yml` | Coordinates the prepare/build/deploy stages |
| `pipeline-stage-prepare.yml` | Ensures that all build/deploy tooling is present on the build agent |
| `pipeline-stage-build.yml` | Performs "build" stage actions, including code checks and unit tests. No changes are pushed to Azure at this time. |
| `pipeline-stage-deploy.yml` | Performs "deploy" stage actions, including management of cloud resources and integration tests. |

### Complex Pipeline Build/Deploy Tasks

In addition to these key workflow components, the following complex build tasks are needed. These build tasks are used to implement the key steps of the CI/CD workflow, and largely originate from Cobalt's own CI/CD processes.

| file | description |
|---|---|
| `tasks/detect-cicd.yml` | Examines the git context and determines if build/deploy should continue |
| `tasks/lint-go.yml` | Performs a linting check on the Go-based unit/integration test code |
| `tasks/lint-tf.yml` | Performs a linting check on the Terraform template files |
| `tasks/tests-unit.yml` | Executes all Go-based unit tests |
| `tasks/tests-int.yml` | Executes all Go-based integration tests |
| `tasks/tf-ws-compute.yml` | Computes a unique Terraform Workspace name to avoid resource race conflicts when manipulating cloud resources in the Azure Subscription |
| `tasks/tf-ws-create.yml` | Creates and selects the Terraform workspace context to be used for resource tracking |
| `tasks/tf-plan.yml` | Captures the output from the Terraform PLAN command in the current workspace and template |
| `tasks/tf-apply.yml` | Applies the current Terraform template into the current workspace |
| `tasks/tf-destroy.yml` | Destroys the resources that were provisioned and tracked in the current workspace |

## Notes for Implementation

- The pipeline should externalize any operational configuration into variable groups
- The pipeline should be able to detect when relevant source-controlled files have been changed, and abort when non-code files have been updated (such as for commits that only include documentation updates)
- A remote Terraform State Container should be configured for storing workspace state (using Azure Blob Storage)
- Terraform Workspace names should be determined through consistently applied computation:
  - Base the WS name on a short identifier, representative of the product
  - Mangle with the environment name
  - For CI/CD initiated due to Pull Request activity, mangle with the short-form PR Number
  - Use this computed name for workspace during both the Build and Deploy stages of the unified pipeline
- All cloud resources should follow a consistent naming pattern to avoid collisions across virtual environments / workspaces. Even though resources are to be partitioned by workspace, these workspaces will generally point to the same underlying Azure Subscription for all dev integration activity.
  - Base the name on a short identifier, representative of the resource's purpose
  - For Resource Group Names and other resource identifiers that require Subscription-wide or Global uniqueness, Mangle with a random character sequence that is stored into the Terraform Workspace (using a `random_string` resource).
  - Enforce resource name restrictions, where required (see [Recommended naming and tagging conventions](https://docs.microsoft.com/en-us/azure/architecture/best-practices/naming-conventions "Naming recommendations"))
- *Implementation of the above mentioned naming recommendations are outside of the scope of the pipeline design, however they imply introduction of additional control parameters into the pipeline's YAML for configuring the behavior of name computations related to PR-triggered pipeline instances and the length of the random string sequences that are generated.*
- Manual Approval for Deployments is enabled on a per-environment basis using the AzDO Portal. For more details see: [Azure DevOps: Approvals and checks](https://docs.microsoft.com/en-us/azure/devops/pipelines/process/approvals "Approvals and checks")

## Relevant Example Code / Configuration Snippets

### Basic YAML Pipeline Scaffolding to Support Multiple Environments

YAML allows for definition of variables as a value list / array. This can be done implicitly within a single YAML, but if we split the pipeline into multiple tiers then we can be more explicit about the structure of those variables while also making the pipeline itself more readable and more easily maintained.

#### Starter code examples for key portions of the YAML pipeline

Structure/pseudocode for main YAML file that is registered as a unified pipeline in AzDO:

```yaml
trigger:
  branches:
    include:
    - master

pr:
  branches:
    include:
    - '*'

stages:
- template: pipeline-cicd.yml
  parameters:
    environments:
    - name: 'devint'
    - name: 'qa'
```

Expands out the environments list and drives build/release stages for each:

```yaml
parameters:
  environments: []

stages:

- ${{ each environment in parameters.environments }}:
  - stage: '${{ environment.name }}_Build'
    jobs:
    - template: pipeline-build-stage.yml
      parameters:
        environment: '${{ environment.name }}'

  - stage: '${{ environment.name }}_Release'
    jobs:
    - template: pipeline-release-stage.yml
      parameters:
        environment: '${{ environment.name }}'
```

Performs the build steps for a given environment:

```yaml
parameters:
  environment: ''

jobs:
- job: 'Build_${{ parameters.environment }}'

  workspace:
    clean: all

  steps:
  - checkout: none
  - download: none

  - task: DownloadBuildArtifacts@0
    displayName: 'Download Build Artifacts'
    inputs:
      artifactName: $(BUILD_ARTIFACT_NAME)
      downloadPath: '$(System.DefaultWorkingDirectory)'

  - template: scripts/test-unit.yml
```

Performs the deployment and integration testing steps for a given environment:

```yaml
parameters:
  environment: ''

jobs:
- deployment: 'Provision_${{ parameters.environment }}'

  variables:
  - group: '${{ parameters.environment }} Environment Variables'

  - name: TF_WORKSPACE_NAME
    value: 'ws_${{ parameters.environment }}'

  environment: '${{ parameters.environment }}'
  strategy:
    runOnce:
      deploy:
        steps:
        - download: none
        - task: DownloadBuildArtifacts@0
          displayName: 'Download Build Artifacts'

        - template: scripts/tf-apply-plan.yml

        - template: scripts/test-integration.yml
```

### Starter code snippets for Unit/Integration Test execution

Build-stage yaml snippets:

```yaml
    - task: GoTool@0
      displayName: 'Verify Go Version is Installed'
      inputs:
        version: '$(GO_VERSION)'

    - template: scripts/test-unit.yml
    - task: AzureCLI@1
      displayName: 'Unit Test Terraform Template'
      env:
        TF_VAR_remote_state_container: $(REMOTE_STATE_CONTAINER)
        TF_VAR_remote_state_account: $(REMOTE_STATE_ACCOUNT)
      inputs:
        azureSubscription: '$(SERVICE_CONNECTION_NAME)'
        addSpnToEnvironment: true
        scriptLocation: inlineScript
        inlineScript: |
          #!/usr/bin/env bash

          set -euo pipefail

          function storageAccountPrimaryKey() {
              az storage account keys list --subscription "$ARM_SUBSCRIPTION_ID" --account-name "$TF_VAR_remote_state_account" --query "[0].value" --output tsv
          }

          function azureTenantId() {
              az account show --query "tenantId" --output tsv
          }

          export ARM_ACCESS_KEY=$(storageAccountPrimaryKey)
          export ARM_CLIENT_SECRET="$servicePrincipalKey"
          export ARM_CLIENT_ID="$servicePrincipalId"
          export ARM_TENANT_ID=$(azureTenantId)

          cd "$ARTIFACT_ROOT"/"$TERRAFORM_TEMPLATE_PATH"

          # Setting the scripts to be run as executable
          chmod -fR 755 *.sh || true

          go test -v $(go list ./... | grep "$TERRAFORM_TEMPLATE_PATH" | grep "unit")
```

Terraform APPLY yaml:

```yaml
  - task: AzureCLI@1
    displayName: 'Apply Resource Changes to Environment'​
    env:​
      TF_VAR_remote_state_container: $(REMOTE_STATE_CONTAINER)​
      TF_VAR_remote_state_account: $(REMOTE_STATE_ACCOUNT)​
      TF_VAR_resource_ip_whitelist: $(TF_VAR_resource_ip_whitelist)​
    inputs:​
      azureSubscription: '$(SERVICE_CONNECTION_NAME)'​
      addSpnToEnvironment: true​
      scriptLocation: inlineScript​
      inlineScript: |​
        #!/usr/bin/env bash​
​
        set -euo pipefail​
        set -o nounset​
​
        function storageAccountPrimaryKey() {​
            az storage account keys list --subscription "$ARM_SUBSCRIPTION_ID" --account-name "$TF_VAR_remote_state_account" --query "[0].value" --output tsv​
        }​
​
        function azureTenantId() {​
            az account show --query "tenantId" --output tsv​
        }​
​
        function terraformVersionCheck() {​
            if [[ $(which terraform) && $(terraform --version | head -n1 | cut -d" " -f2 | cut -c 2\-) == $TF_VERSION ]]; then​
                echo "Terraform version check completed"​
              else​
                TF_ZIP_TARGET="https://releases.hashicorp.com/terraform/$TF_VERSION/terraform_${TF_VERSION}_linux_amd64.zip"​
                echo "Info: installing $TF_VERSION, target: $TF_ZIP_TARGET"​
        ​
                wget $TF_ZIP_TARGET -q​
                unzip -q "terraform_${TF_VERSION}_linux_amd64.zip"​
                sudo mv terraform /usr/local/bin​
                rm *.zip​
            fi​
            ​
            terraform -version​
​
            # Assert that jq is available, and install if it's not​
            command -v jq >/dev/null 2>&1 || { echo >&2 "Installing jq"; sudo apt install -y jq; }​
        }​
​
        terraformVersionCheck​
​
        cd $TF_TEMPLATE_WORKING_DIR​
​
        # Setting the scripts to be run as executable​
        chmod -R 752 .terraform​
​
        export ARM_ACCESS_KEY=$(storageAccountPrimaryKey)​
        export ARM_CLIENT_SECRET=$servicePrincipalKey​
        export ARM_CLIENT_ID=$servicePrincipalId​
        export ARM_TENANT_ID=$(azureTenantId)​
​
        TF_PLAN_FILE="${TF_WORKSPACE_NAME}_plan.out"​
        TF_CLI_ARGS=${TF_CLI_ARGS:-}​
​
        terraform apply $TF_CLI_ARGS -input=false -auto-approve $TF_PLAN_FILE​
```

Deploy-stage integration testing YAML:

``` yaml
  - task: AzureCLI@1
    displayName: 'Integration Test Terraform Template'​
    env:​
      TF_VAR_remote_state_container: $(REMOTE_STATE_CONTAINER)​
      TF_VAR_remote_state_account: $(REMOTE_STATE_ACCOUNT)​
    inputs:​
      azureSubscription: '$(SERVICE_CONNECTION_NAME)'​
      addSpnToEnvironment: true​
      scriptLocation: inlineScript​
      inlineScript: |​
        #!/usr/bin/env bash​
​
        set -euo pipefail​
​
        function storageAccountPrimaryKey() {​
            az storage account keys list --subscription "$ARM_SUBSCRIPTION_ID" --account-name "$TF_VAR_remote_state_account" --query "[0].value" --output tsv​
        }​
​
        function azureTenantId() {​
            az account show --query "tenantId" --output tsv​
        }​
​
        export ARM_ACCESS_KEY=$(storageAccountPrimaryKey)​
        export ARM_CLIENT_SECRET="$servicePrincipalKey"​
        export ARM_CLIENT_ID="$servicePrincipalId"​
        export ARM_TENANT_ID=$(azureTenantId)​
​
        cd "$ARTIFACT_ROOT"/"$TERRAFORM_TEMPLATE_PATH"​
​
        # Setting the scripts to be run as executable​
        chmod -fR 755 *.sh || true​
​
        go test -v $(go list ./... | grep "$TERRAFORM_TEMPLATE_PATH" | grep "integration")​
```

## Proposal in image form

![CICD](./.design_images/CICD_Pipeline_v2.png "CI/CD")

Source: [CI/CD Diagram Source](./.design_images/CICD_Pipeline_v2.drawio "CI/CD")

### Primary Risks

- Evaluation of GitLab-hosted pipelines and/or repositories produced a number of findings that indicate some risk with this solution:
  - Pull Request triggers might not work as expected when an AzDO Pipeline is configured with a GitLab-hosted repository
  - GitLab Pipelines appear to support all (or most) of the CI/CD features being leveraged in this AzDO-based pipeline, however the YAML dialect and structure being used is quite different. If the CI/CD for infrastructure is migrated to GitLab in the future, the YAML will need to be re-written for that platform.
  - Gated deployments and multiple code reviewers are Premium GitLab features (not an issue today, but could be a factor if that situation changes).
  - GitLab Pipelines do not supply default Build Agents. These will need to be provided and maintained by the engineering team.
