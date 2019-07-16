# Managed Container Service Deployments with GitHub Flow 

An Azure Pipeline template responsible for building application images from Git and pushing them to Azure Container Registry and auto deploy to app service(s).

![image](https://user-images.githubusercontent.com/7635865/61189483-f29df000-a642-11e9-9fd6-f4476c72ac66.png)

## Pipeline Setup

Technical operators should setup one pipeline for each app service.

### Prerequisite Checklist

- ✅ Do - Infrastructure [resources](../infrastructure/README.md) are provisioned across all environment stages.
- ✅ Do - Container project is hosted on either a private or public Git repository.
- ✅ Do - Container repository contains a docker manifest file(e.g. Dockerfile).
- ✅ Do - Azure DevOps project is setup.
- ✅ Do - Container git repo is configured as an artifact source in the Azure DevOps project. n
- ✅ Do - Service principal credentials are configured as Azure DevOps KeyVault-linked Variable Groups(one variable group for each release stage). This pipeline requires the service principal to have a contributor role assignment for both the ACR and app service instance(s). Both the creation of the service principal and it's integration into keyvault are automated as part of the infrastructure [pipeline](../infrastructure/README.md).

### Add Pipeline

- Within your azure devops project, create a new pipeline

![image](https://user-images.githubusercontent.com/7635865/56069362-549b4080-5d48-11e9-97b9-02cb01cc5b35.png)

- Select GitHub as your source

![image](https://user-images.githubusercontent.com/7635865/56069729-05eea600-5d4a-11e9-8aa8-002feb8519a0.png)

- After selecting your service connection, provide the location of your target repository.

![image](https://user-images.githubusercontent.com/7635865/56069808-5fef6b80-5d4a-11e9-9d5d-d4a7fb372a41.png)

- Point the build definition to the repository's target yaml pipeline location.

![image](https://user-images.githubusercontent.com/7635865/56069873-a5ac3400-5d4a-11e9-80e0-fe2e90b5639b.png)

![image](https://user-images.githubusercontent.com/7635865/56069976-2c611100-5d4b-11e9-9bc0-b4dad6d1cd9c.png)

### Git: Master Branch Policies for Application Container Repo

We strongly recommend adding branch policies to help protect the master branch and configure mandatory validation builds to avoid simultaneous builds when merging into master.

![image](https://user-images.githubusercontent.com/7635865/60196805-97c36680-9803-11e9-9fd0-7bedc34fc9ad.png)

Here's some more [guidance](https://docs.microsoft.com/en-us/azure/devops/pipelines/repos/github?view=azure-devops&tabs=yaml#protecting-branches) on leveraging Azure DevOPS build validation checks with protected branch's.

#### Recommended Branch Policies

- ✅ Do - Require pull request reviews before merging.
- ✅ Do - Prevent force pushing e.g. to prevent rewriting the commit history.
- ✅ Do - Require completion of Production stage release in Azure DevOPS before merging.
- ✅ Do - Prevent parallel releases into DevInt, QA, staging and production environments.
- ✅ Do - Require status checks to pass before merging changes into the protected branch.

## In Scope

- Design of Azure DevOps pipeline
- Sequence diagram showing the journey with sourcing, testing, building and releasing the image artifact across all azure environment stages.

## Out of Scope

- Chaos Testing
- Load Testing
- Build Agent Pool Setup

## Pipeline Definition

This template bootstraps a new pipeline in Azure DevOps that automatically builds, validates and releases an docker image to a target app service on every pull request and/or commit to your source git repository hosting the container source artifacts.

### Pipeline Sequence Diagram

This graphic shows the CI/CD workflow topology for the unified Azure DevOps template that manages the container lifecycle.

![image](https://user-images.githubusercontent.com/7635865/61230178-2fbfbc00-a6ef-11e9-82bf-24137b722c1a.png)

### Build

The build stage runs through a series of automated repeatable checks to validate the changes within the release candidate. This pipeline ships with build tasks for code security breach scans, end-to-end integration test and docker image security scans. Our recommendation is asserting automated tests such as documentation style checks, lint rule validations, unit tests and [minimum](https://martinfowler.com/bliki/TestCoverage.html) acceptable code coverage as part of your docker build process. One good example of this strategy is the test harness usage of setup [tools](https://github.com/michaelperel/putput/blob/master/setup.py) within the [`Dockerfile`](https://github.com/michaelperel/putput/blob/master/Dockerfile#L9) from the putput project.

The pipeline will build the docker image and push to the configured ACR instance once all automated checks have passed. The docker manifest file defaults to `Dockerfile` from the root directory of the repo and can be overridden with the `DOCKERFILE_PATH` pipeline variable. Azure DevOps will send a notification for any build or automated test failures. You can configure build and release notification settings by following these [instructions](https://docs.microsoft.com/en-us/azure/devops/notifications/howto-manage-team-notifications?view=azure-devops).

The docker image serves as the build artifact promoted across all application release stages.

This pipeline includes a task that [publishes](https://docs.microsoft.com/en-us/azure/devops/pipelines/tasks/test/publish-test-results?view=azure-devops&tabs=yaml) both the automated test results and coverage report to Azure DevOPS so app dev teams can monitor test and coverage improvements over time.

#### Build Artifact

Once all build tasks are completed, the pipeline will push the docker image artifact to the ACR instance configured within the Dev Integration stage(e.g. the pipeline variable `ACR_RESOURCE_NAME`). The image will be tagged to the Azure DevOps `BUILD_ID` and name sourced from the `APP_SERVICE_IMAGE_NAME` pipeline variable. 

The pipeline will also build the docker image responsible for running your end-to-end integration tests. The location of the dockerfile is sourced from the `DOCKERFILE_INT_TEST_PATH` pipeline variable. The image will be tagged to `{APP_SERVICE_IMAGE_NAME}-IntTests:{BUILD_ID}` and pushed to the Dev Integration ACR instance.

### Release Stages

The same docker image artifact is promoted across all four azure environments managed by gate approvals in QA, Staging and Production. Each stage creates a release tag in ACR which triggers the automated deployment to app service then runs the integration test suite container for end-to-end testing.

![image](https://user-images.githubusercontent.com/7635865/61192206-a1ecbe00-a667-11e9-9725-d2f0174cab89.png)

Each release stage is configured with a keyvault-linked variable group and the azure environment subscription id(e.g. `AZURE_SUBSCRIPTION_ID` release variable).

Parallel releases are disabled on all agent pools as these are dedicated app service environments.

#### Dev Integration

The ACR webhook is configured to auto deploy images tagged with `release-devint` to app service. We create the release tag in ACR and wait until the container is online. We then run the integration test container which probes and inspects the deployed application container running in app service. These integration tests run on each commit to the source git repo.

#### QA

This environment is a lighter weight replica of staging and intended for manual quality assurance checkouts. There's a gate approval for creating the `release-qa` tag in ACR which triggers the webhook deployment to app service. Once the gate is approved the pipeline will wait until the container is online. We then run the integration test container which probes and inspects the deployed application container running in app service.

#### Staging

The staging environment is a 1:1 replica of the production environment. To support highly available data center outage scenarios, we follow a dual region deployment for each container release. This environment's app service is setup with a staging slot to support [canary releases](https://martinfowler.com/bliki/CanaryRelease.html).

The first step in this stage is to create the `release-staging` tag in ACR which triggers the webhook deployment to the staging app service slot. The staging app service slot is referenced when running the integration test container. A gate approval request is submitted when all automated tests have passed. Once the gate is approved, we auto swap the app service slots between staging and live.