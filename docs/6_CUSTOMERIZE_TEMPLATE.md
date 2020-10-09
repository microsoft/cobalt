# 6. Customerizing a Template

## 6.1 Overview
We've reached a point in the walk-through where we have Cobalt ready for prime time. We have the HLD repo setup with our custom temple complete with tests. Now we have applications or teams that would like to deploy their code into the infrastructure that this template would create. To do this Cobalt uses the concept of "version and go". This simply means you reference a version of the template and pipeline from the application repo. These references reference a specific version ie. 1.2.3. 

## 6.2 Goals and Objectives
To save so much time that we can actually enjoy our log walks on the beach, horse back rides, video game competition, whatevs... 
 - To create a file that references the template in the HLD repo and sets required params
 - To create a file that references the pipeline in the HLD repo
 - To set up a pipeline and the required variable groups to deploy the infra for a app

## 6.3 Prerequisites

You have to have this stuff in place to move forward in life... Start here.

 1. Terraform -> Really! See the Quick start
 2. AzCli -> See item 1
 3. HLD Repo -> Basically do the Quick Start -> Operationalize Docs.

### 1. Setup Environment Variables

Define variables for ease of execution of snippets below.

| Variable | Sample Value | Description |
|----------|--------------|-------------|
| `APP_DEVOPS_PROJECT_NAME` | `My Application` | The name of the project representing your application that could include both your Cobalt foundation in addition to any application code, pipelines, boards, or artifacts. |
| `APPS_DEVOPS_INFRA_REPO_NAME` | `infrastructure` | The name of the repo that will be created in the application Azure DevOps project to host the Cobalt template. |
| `APP_DEVOPS_INFRA_YML_PATH` | `devops/providers/azure-devops/templates/azure-pipelines.yml` | The path relative to the `APPS_DEVOPS_INFRA_REPO_NAME` root that contains the Cobalt template pipeline to be created for provisioning application resources. |
| `DEFAULT_ORGANIZATION` | `https://dev.azure.com/MyOrganization/` | The full URL path of the organization in which your `APP_DEVOPS_PROJECT_NAME` resides or will be created. |
| `GIT_SOURCE_URL` | `https://dev.azure.com/MyOrganization/MyProject/_git/MyCobaltTemplateRepo` | The Git clone URL for the repository hosting the Cobalt template on which your project will be built. |

Update these values for your environment and application based on the guidance in the table above.
```bash
export APP_DEVOPS_PROJECT_NAME=""
export APP_DEVOPS_INFRA_REPO_NAME=""
export APP_DEVOPS_INFRA_YML_PATH=""
export DEFAULT_ORGANIZATION=""
export GIT_SOURCE_URL=""
```

The following values are used like constants and should not need to change (unless the build pipeline definition is modified).
```bash
export COBALT_VAR_GROUP_INFRA="Infrastructure Pipeline Variables"
export COBALT_VAR_GROUP_ENV_SUFFIX="Environment Variables"
export COBALT_PIPELINE_NAME="Cobalt CICD Pipeline"
```

> NOTE: Before you can run Azure DevOps CLI commands, you need to run the login command (`az login` if using AAD/MSA identity else `az devops login` if using PAT token) to setup credentials. Please see https://aka.ms/azure-devops-cli-auth for more information.


## 6.4 Walkthrough

This walkthough picks up after 5. Operationalize Template Documentation. We are focused mainly on the repository that contains the application to be deployed. The app repo should be located in same AzDO Organization, but in a different project.

### Create Application.tf
The `application.tf` file configures the application specific settings for the Template to be deployed.

```
module "az-hello-world" {
  source                  = "git::https://dev.azure.com/cseblack/TestCobalt/_git/Cobalt-Hello-World-Ian//infra/templates/az-hello-world?ref=0.0.1"
  resource_group_location = "eastus"
  prefix                  = "az-hello-world-iptest"
  deployment_targets = [{
    app_name                 = "cobalt-backend-api-iptest",
    image_name               = "appsvcsample/static-site",
    image_release_tag_prefix = "latest"
  }]
}
```

### Create Application.yaml
The `application.yaml` file configures the pipeline used to build/test/deploy the template to Azure.

```
# Repo: Contoso/WindowsProduct
# File: azure-pipelines.yml
resources:
  repositories:
    - repository: templates
      type: git
      name: TestCobalt/Cobalt-Hello-World-Ian
      # ref: refs/tags/v1.0 # optional ref to pin to

stages:
- template: devops/providers/azure-devops/templates/infrastructure/azure-pipelines-app.yml@templates  # Template reference
  parameters:
    environments:
    - 'devint'

    configurationMatrix:
    - jobName: az_hello_world
      terraformTemplatePath: 'infra/'
      terraformWorkspacePrefix: 'hw'
      environmentsToTeardownAfterRelease:
      - 'devint'
```

### Save to infra/ in app repo
This is the location that the pipeline will expect the cobalt CIT files.

```
Repo
  |__infra/
       |__application.tf
       |__application.yaml
```

### Setup pipeline
We have the configuration files in the correct location. We need to create a new pipeline using the YAML.

Create the build pipeline. We are intentionally skipping the initial run since we know it will fail; we need to link the required variables groups to this pipeline, and currently that cannot be done directly through the Azure DevOps CLI.

```bash
az pipelines create --name "$COBALT_PIPELINE_NAME" --repository "$APP_DEVOPS_INFRA_REPO_NAME" --branch master --repository-type tfsgit --yml-path $APP_DEVOPS_INFRA_YML_PATH --skip-run true
```

### Setup Pipeline Variables
These variables contain the configuration elements needed for the pipeline to properly build/test/deploy the application infrastructure.

Variable groups are utilized by the pipeline to configure how the Cobalt template will be tested and deployed. The `az pipelines variable-group create` `--variables` flag expects a list of space-delimited key value pairs (e.g., `KEY1='val1' KEY2=true`).

The following *Infrastructure Pipeline Variables* are used by all possible environment-specific executions for the Cobalt pipelines.

```bash
# IMPORTANT: Replace these values as necessary to fit your environment.
az pipelines variable-group create --authorize true --name "$COBALT_VAR_GROUP_INFRA" --variables \
    AGENT_POOL='Hosted Ubuntu 1604' \
    ARM_PROVIDER_STRICT=true \
    BUILD_ARTIFACT_NAME='drop' \
    BUILD_ARTIFACT_PATH_ALIAS='artifact' \
    GO_VERSION='1.12.5' \
    PIPELINE_ROOT_DIR='devops/providers/azure-devops/templates/infrastructure' \
    REMOTE_STATE_CONTAINER='BACKENDSTATECONTAINERNAME' \
    SCRIPTS_DIR='scripts' \
    TEST_HARNESS_DIR='test-harness/' \
    TF_DEPLOYMENT_TEMPLATE_ROOT='infra/templates/az-hello-world' \
    TF_DEPLOYMENT_WORKSPACE_PREFIX='PROJECTDEPLOYMENTWORKSPACEPREFIX' \
    TF_ROOT_DIR='infra' \
    TF_VERSION='0.12.4' \
    TF_WARN_OUTPUT_ERRORS=1
```

Within the pipeline build definition you may specify the number of environments that will be targed for deployment. For each environment specified, you will need a variable group that defines the Azure Subscription ID to where the infrastructure will be provisioned. You will also need to set a Service Connection that has permissions to provision resources on that subscription.

For this walkthrough, we will only create a single environment -- *devint*. The following commands will create the required *DevInt Environment Variables* variable group.
```bash
# IMPORTANT: Replace these values as necessary to fit your environment.
DEVINT_VAR_GROUP="DevInt $COBALT_VAR_GROUP_ENV_SUFFIX"
az pipelines variable-group create --authorize true --name $DEVINT_VAR_GROUP --variables \
    ARM_SUBSCRIPTION_ID='TARGETSUBSCRIPTIONID' \
    REMOTE_STATE_ACCOUNT='BACKENDSTATESTORAGEACCOUNTNAME' \
    SERVICE_CONNECTION_NAME='SERVICECONNECTIONNAME' \
    TF_CLI_ARGS=''
```

### Build/test/deploy
Now we run the pipeline to build, test, and deploy our new infrastructure. After the infrastructure is deployed, the app will need it's own pipeline to deploy it's self to the newly minted resources in Azure.

Queue a pipeline to run.
```bash
az pipelines run --name "$COBALT_PIPELINE_NAME"
```