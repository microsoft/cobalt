# Infrastructure Continuous Integration and Deployment Pipeline

Azure Pipeline build and release templates responsible for operationalizing infrastructure resources with a focus on repeatability and test automation.

## Introduction

Azure Devops is the common fabric between developers, process and products to enable continuous delivery of value to customers.

Cobalt's devops release flow follows a git commit driven model. Meaning that azure pipelines automatically builds, validates and release Cobalt templates every pull request and commit to your source git repository, essentially applying the GitOps pattern to the Azure PaaS services.

This document outlines how Cobalt's CI/CD Azure Pipeline templates will be used to meet the devops related use-cases for deployment operators working on Cobalt.

## Goal

Provide Cobalt technical operators with a general use case Azure DevOps pipeline. Operators can import this yaml based template when creating their pipeline in the Azure DevOPS portal.

## Pipeline Sequence Diagram

This graphic shows the CI/CD workflow topology needed by our enterprise customers to deploy infrastructure to Azure. The journey starts with a git commit to the [IAC](https://blog.scottlogic.com/2018/10/08/infrastructure-as-code-getting-started-with-terraform.html)(Infrastructure-as-code) repository. This workflow validates and deploys the desired infrastructure state across the azure environments.

![infrastructure_reference_cicd_flow](../../../../../design-reference/devops/providers/azure/infrastructure_reference_cicd_flow.jpg)

## In Scope

- Design of Azure DevOps build template
- Sequence diagram showing the journey with sourcing, testing, building and releasing IAC(Infra-as-code) templates across azure environment stages.

## Out of Scope

- Observability
- Monitoring
- Azure Boards
- Automating the provisioning of the azure devops pipeline prerequisites
- Implementation details of the Azure Pipeline Template.
- Automated load testing
- Chaos testing
- Active Directory Setup
- Multi-region deployments
- Build Agent Pool Setup
- Remote terraform modules for auto scaling and monitoring rules

## Customers

- **Technical Operators**: This template uses a service principal to carry out the terraform resource provisioning. The deployment service principal will need contributor role level permissions on the cloud resources.

    Provisioning templates that modify role assignments will require owner level access to the target resource(s).

## Prerequisites

- An provisioned Azure DevOps instance
- Service principal
- Storage account for tracking remote terraform state. We recommend [backing](https://azure.microsoft.com/en-us/services/backup/) this storage account up in Azure.
- Key Vault resource including the service principal and storage account credentials following these [instructions](../../README.md#required-key-vault-secrets).
- A git repo containing the terraform deployment template(ie Github, Github Enterprise, Azure DevOPS git, etc).
- Azure DevOPS Github integration installed on the upstream repo

## Build Pipeline

### Description

The goal for this particular pipeline is to download the target cobalt template manifest artifacts onto the build agent and apply the terraform execution plan onto the Dev Integration environment.

The build will reconcile the current environment cloud resource state with the desired resource state to determine which resources to add, remove or modify. Terraform uses a remote storage account residing in each Azure environment to maintain latest state.

Once the resources have been provisioned within the Dev Int Environment, the test harness will run the automated unit and integration tests to validate the functionality end-to-end.

The test harness will automatically tear down all provisioned resources to help minimize azure costs and duplicate cloud objects.

### Build Trigger

- Cobalt is a library of infrastructure manifests represented as Terraform templates(aka IAC: Infrastructure as Code).

- Each template defines multiple composable building-block terraform modules and assembles them together to produce a larger system.

- This pipeline's deployment process is built around a repo that holds the template to provision.

- Operational changes are made to the running system by making commits on this repo.

- Follow these [instructions](https://docs.microsoft.com/en-us/azure/devops/pipelines/repos/github?view=azure-devops&tabs=yaml#private-github-repository-or-azure-pipelines-in-a-private-project) to link the IAC repo to the build pipeline.

- Here's some more [background](https://docs.microsoft.com/en-us/azure/devops/pipelines/repos/github?view=azure-devops&tabs=yaml#ci-triggers) on how CI triggers work in Azure DevOPS. 

- The build pipeline is triggered on new commits made to any feature branch.

#### Getting the source code

The linked IAC git repo will be cloned and pulled onto the build agent machine. Here's some more [info](https://docs.microsoft.com/en-us/azure/devops/pipelines/repos/github?view=azure-devops&tabs=yaml#getting-the-source-code) on how that will operate from the perspective of the Azure unified pipeline.

#### Git: Master Branch Policies for IAC Repo

We strongly recommend adding branch policies to help protect the master branch and configure mandatory validation builds to avoid simultaneous builds when merging into master.

![image](https://user-images.githubusercontent.com/7635865/60196805-97c36680-9803-11e9-9fd0-7bedc34fc9ad.png)

Here's some more [guidance](https://docs.microsoft.com/en-us/azure/devops/pipelines/repos/github?view=azure-devops&tabs=yaml#protecting-branches) on leveraging Azure DevOPS build validation checks with protected branch's.

#### Recommended Branch Policies

- ✅ Do - Require pull request reviews before merging.
- ✅ Do - Prevent force pushing e.g. to prevent rewriting the commit history.
- ✅ Do - Require completion of Production stage release in Azure DevOPS before merging.
- ✅ Do - Prevent parallel releases into QA, staging and production environments.
- ✅ Do - Require status checks to pass before merging changes into the protected branch.

### Published Artifact

The Terraform workspace directory is published as a pipeline build [artifact](https://docs.microsoft.com/en-us/azure/devops/pipelines/artifacts/build-artifacts?view=azure-devops&tabs=yaml#how-do-i-publish-artifacts) following the automated test step(s). This artifact ensures that the same manifest is applied across all release stages.

## Release Stages

### QA

This environment is a lighter weight replica of staging and intended for manual quality assurance checkouts. Automated terraform tests are asserted against this environment, similar to DevInt.

This Azure Devops stage does not support parallel releases due to the dedicated resources.

#### Release Gate

There's a gate prior to applying the execution plan onto the QA environment. The technical operator should review the terraform execution plan prior to approving the gate request.

#### Stage Completion

The Staging release will be automatically triggered upon a successful completion / release of this stage.

### Staging

The staging environment is a 1:1 replica of the production environment.

Cobalt automated tests should be tagged to application environment targets to avoid automated tests that happen to mutate data in production.

This Azure Devops stage does not support parallel releases due to the dedicated resources.

#### Release Gate

There's a gate prior to applying the execution plan onto the Staging environment. The technical operator should review the terraform execution plan prior to approving the gate request.

### Production

The production stage release is auto triggered upon feature branch merges into master. This stage will apply the desired terraform changes within your production environment.

One git scm flow worth considering is the [GitHub flow](https://guides.github.com/introduction/flow/). This model promotes short feedback loops for feature branch pull requests. This means work branches (‘work’ could mean a new feature or a bug fix – there is no distinction) starts from the production code (master) and are short lived.

Our pipeline can support any scm git workflow(gitflow, etc).

The master branch is a record of known good production code. Feature branch(s) should only be merged into master once: 1) code review's are approved 2) all CD pre-prod releases are complete. These can be validated as part of your master branch policy.

This Azure Devops stage does not support parallel releases due to the dedicated resources.

## Pipeline setup

As discussed earlier, there's one git repository for each infrastructure template, as technical operators are code owners of cloud resource manifests.

### Add Baseline Azure Build Pipeline

- Within your azure devops project, create a new pipeline

![image](https://user-images.githubusercontent.com/7635865/56069362-549b4080-5d48-11e9-97b9-02cb01cc5b35.png)

- Select GitHub as your source

![image](https://user-images.githubusercontent.com/7635865/56069729-05eea600-5d4a-11e9-8aa8-002feb8519a0.png)

- After selecting your service connection, provide the location of your target repository.

![image](https://user-images.githubusercontent.com/7635865/56069808-5fef6b80-5d4a-11e9-9d5d-d4a7fb372a41.png)

- Point the build definition to the repository's target yaml pipeline location.

![image](https://user-images.githubusercontent.com/7635865/56069873-a5ac3400-5d4a-11e9-80e0-fe2e90b5639b.png)

![image](https://user-images.githubusercontent.com/7635865/56069976-2c611100-5d4b-11e9-9bc0-b4dad6d1cd9c.png)

### Application Dev Team Pipeline Setup

There should be one Azure Unified pipeline for each individual application. This can be achieved by cloning the baseline build definition for each application per azure devops instance.

![image](https://user-images.githubusercontent.com/7635865/60265046-44582380-98aa-11e9-9644-4d04cb561b79.png)

## Variable Groups for Pipeline Configuration

There are two flavors of variables that need to be created, and each should be created as a library within Azure DevOps. You will need to ensure that the libraries are correctly linked to the pipeline before your build/release will work.

### Global Variable Group

This group can have any name (i.e., `Infrastructure Pipeline Variables`) and you will need to link it to the pipeline in the Azure DevOps tool. It will need the following variables defined:

| Variable Name | Description | Sample Value |
| ------------- | ------------- | ------------- |
| `AGENT_POOL` | The Azure DevOPS agent pool name | `Hosted Ubuntu 1604` |
| `BUILD_ARTIFACT_NAME` | The build artifact naming prefix | `drop` |
| `BUILD_ARTIFACT_PATH_ALIAS` | Alias for build artifact | `artifact` |
| `GO_VERSION` | The Go version to use for the automated test steps | `1.12.5` |
| `PIPELINE_ROOT_DIR` | The relative path of the Azure DevOPS CI/CD pipeline directory | `devops/providers/azure-devops/templates/infrastructure` |
| `REMOTE_STATE_CONTAINER` | The remote state Azure storage container name | `cobaltfstate-remote-state-container` |
| `SCRIPTS_DIR` | The directory name containing the scripts used for the Azure DevOPS pipeline | `scripts` |
| `ARM_PROVIDER_STRICT` | Whether or not to enable strict mode in terraform [`true`|`false`] | `true` |
| `TEST_HARNESS_DIR` | Relative directory of test harness | `test-harness/`
| `TF_DEPLOYMENT_TEMPLATE_ROOT` | Relative directory of template to deploy | `infra/templates/ |az-isolated-service-single-region` |
| `TF_ROOT_DIR` | Relative directory of terraform root | `infra/` |
| `TF_VERSION` | Version of terraform | `0.12.4` |
| `TF_WARN_OUTPUT_ERRORS` | Flag for terraform that results in no failures for a warning | 1 |

### Stage Specific Pipeline Variables

This group has to be named `$STAGE Environment Variables`. It will need the following variables defined:


| Variable Name | Description | Sample Value |
| ------------- | ------------- | ------------- |
| `ARM_SUBSCRIPTION_ID` | The Azure subscription of the service principal used for the deployment | 98z7y6x5-w43v-2198-765u-ts43r21q9876 |
| `REMOTE_STATE_ACCOUNT` | The Azure storage account for remote terraform state | cobaltfstate |
| `SERVICE_CONNECTION_NAME` | The azure devops service connection name to use for the Terraform deployments | Cobalt Deployment Administrator |
| `TF_CLI_ARGS` | specify additional arguments to the command-line. This allows easier automation in CI environments as well as modifying default behavior of Terraform. If nothing is passed in to this variable, Terraform's default behavior will take place | -refresh=false |

## Security

Deployments are carried out by service principals. The build pipeline references SP by leveraging a service connection (described above). No secrets need to be defined in variables or KeyVault.
