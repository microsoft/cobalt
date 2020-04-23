## Maven Service deployments into Azure via Azure DevOps

This document describes how to deploy a **Maven Service** to Azure in Azure Devops by taking advantage of the **Shared Maven Service Pipeline** build and release templates that can be re-used across Maven Services.

### Prerequisites

- A running App Service deployed from a Cobalt Infrastructure Template.
- A **Maven Service**

### Step 1: Prepare project structure

Ensure project files (i.e. `settings.xml`, `*.jar`, `pom.xml`, ) can be found relative to the service pipeline `yaml` file. The devops pipelines will need to be configured to consume file paths in the next step.

    ```bash
    $ tree myjavacontainerapp/provider/javahelloworld-azure
    ├───pom.xml
    ├───devops/entry_point.yml
    └───maven
    │    ├───settings.xml
    |    └───...
    └───javahelloworld-test-azure
          └───pom.xml
              ├───...
              └───..
    ```

### Step 2: Configure the devops pipelines

The starting point of a **Maven Service** deployment will live in the application code repository. This starting point passes values to the **Shared Maven Service Pipeline**. The Shared Maven Service Pipeline will need to be configured in Azure DevOps. The instructions to do this can be found [here](https://docs.microsoft.com/en-us/azure/devops/pipelines/get-started/pipelines-get-started?view=azure-devops#define-pipelines-using-yaml-syntax). Here is what the starting point of a **Maven Service** pipeline might look like:

```yaml
# Omitting PR and Trigger blocks...

variables:
  - group: 'Azure - Common'

  - name: serviceName
    value: 'JavaHelloWorld'

resources:
  repositories:
    - repository: cobalt
      type: git
      name: <<$AZURE_DEVOPS_HOST_PROJECT_NAME>>/cobalt

stages:
  - template: devops/providers/azure-devops/templates/app_service_maven/build-stage.yml@cobalt
    parameters:
      copyFileContents: |
        pom.xml
        maven/settings.xml
        target/*.jar
      mavenOptions: '--settings ./maven/settings.xml' # ex. Basic example of passing extra context to your maven build task
      serviceBase: ${{ variables.serviceName }}
  - template: devops/providers/azure-devops/templates/app_service_maven/deploy-stages.yml@cobalt
    parameters:
      serviceName: ${{ variables.serviceName }}
      providers:
        -  name: Azure
           # Merges into Master
           ${{ if eq(variables['Build.SourceBranchName'], 'master') }}:
             environments: ['devint', 'qa', 'prod']
           # PR updates / creations
           ${{ if ne(variables['Build.SourceBranchName'], 'master') }}:
             environments: ['devint']
```

Services will typically leverage the following common templates to configure their build and release stages. All configurations can be overridden:

- `devops/providers/azure-devops/templates/app_service_maven/build-stage.yml`

- `devops/providers/azure-devops/templates/app_service_maven/deploy-stages.yml`

  **Required Configurations**

  - `repositories` keyword mapping: This is the syntax needed to reference an external repository. The **Shared Maven Service Pipeline** templates live in the infrastructure repository and not in the service repository with the **Maven Service**.
  - `template` attribute keyword: This is the syntax needed to use another `yaml` file as a template. The `yaml` files being referenced must be either the full path to the build stage `yaml` file or the deploy stages `yaml` file.
  - `copyFileContents` or `copyFileContentsToFlatten` parameter: Either or both of these parameters must be satisifed with the paths that point to the files you want packaged up and passed as build artifacts.

  The following key areas impact the variable groups that are required for the pipeline:

  - Parameter which defines the `providers`. This controls which cloud provider the application will be deployed to. In this example, we use Azure.
  - Stanza which defines the `environments`. This controls which environment the application will be deployed to. It should match the environments configured in the infrastructure pipeline. In the example shown here, the environments deployed will depend on whether or not the build has been triggered from the `master` branch. This enables PR builds to deploy only to `devint`.
  - Stanza which defines  the `serviceBase`: This controls the name of the Maven Service being deployed. It should be unique for each Maven Service being deployed. In this example, we use `JavaHelloWorld` as a generic service application name.

  **Optional Parameters**

  - `mavenOptions` Use this parameter to pass additional values to your settings.xml file.
  - `mavenGoal`: Use this parameter to pass in different build lifecycle commands
  - `testingRootFolder`: Use this parameter to pass the path to your service's integration tests.
  - `mavenPomFile`: 'Use this parameter to pass the path to your pom file.

### Step 3: Configure the Azure DevOps Variable Groups

Variable groups are named in a way that allows the **Shared Maven Service Pipeline** to look up rather or not the group belongs to a specific cloud provider and for which environment should the group be used for. The following tables describe the variable group names required to support a service deployment. The value columns provide concrete examples for how one might satisfy the variables in each group.

`Azure - Common`

  This group is holding the majority of variables needed to deploy a **Maven Service**.

  | name | value | description | sensitive? | source |
  | ---  | ---   | ---         | ---        | ---    |
  | `AGENT_POOL` | `Hosted Ubuntu 1604` | Agent on which to run release | no | ADO |
  | `AZURE_AD_APP_RESOURCE_ID` | `$(aad-client-id)` | see `aad-client-id` | yes | ADO - see `Azure Target Env Secrets - $ENV` |
  | `AZURE_DEPLOY_APPSERVICE_PLAN` | `$(ENVIRONMENT_RG_PREFIX)-$(PREFIX_BASE)-sp` | App Service Plan in which the App Service lives | no | ADO - see `Azure Target Env - $ENV` |
  | `AZURE_DEPLOY_CLIENT_ID` | `********` | Client ID used to deploy to Azure | yes | ADO |
  | `AZURE_DEPLOY_CLIENT_SECRET` | `********` | Client secret for `AZURE_DEPLOY_CLIENT_ID`. | yes | ADO |
  | `AZURE_DEPLOY_RESOURCE_GROUP` | `$(ENVIRONMENT_RG_PREFIX)-$(PREFIX_BASE)-app-rg` | Resource group in which the App Service Plan lives | no | ADO - see `Azure Target Env - $ENV` |
  | `AZURE_DEPLOY_TENANT` | `********` | Tenant linked to subscription.| yes | ADO |
  | `AZURE_TESTER_SERVICEPRINCIPAL_SECRET` | `$(app-dev-sp-password)` | see `app-dev-sp-password` | yes | ADO - see `Azure Target Env Secrets - $ENV` |
  | `AZURE_HELLOWORLD_SERVICE_NAME` | `$(ENVIRONMENT_SERVICE_PREFIX)-javahelloworld` | Name of App Service for a java service | no | ADO - see `Azure Target Env - $ENV` |
  | `CONTAINER_REGISTRY_NAME` | `$(ENVIRONMENT_STORAGE_PREFIX)cr` | ACR name for holding jar files as an image | no | ADO - see `Azure Target Env - $ENV` |
  | `HELLOWORLD_URL` | ex `https://$(AZURE_HELLOWORLD_SERVICE_NAME).azurewebsites.net/` | Endpoint for a java service | no | ADO |
  | `INTEGRATION_TESTER` | `$(app-dev-sp-username)` | see `app-dev-sp-username` | yes | ADO - see `Azure Target Env Secrets - $ENV` |
  | `PREFIX_BASE` | ex. `organization-name` | Prechosen prefix created by infrastructure deployment | no |  ADO - see `Azure Target Env - $ENV` |
  | `SERVICE_CONNECTION_NAME` | ex `cobalt-service-principal` | Default ADO Service Connection name for deployment | no | ADO |  

`Azure Target Env Secrets - $ENV`

  This group holds the key vault `secret names` a service deployment environment will use to access key vault `secret values` held within a key vault account. The Azure Service Principal used to deploy the infrastructure must be granted Key Management Operations. These values are ultimately passed to the settings.xml file for deployment and integration tests.

  > `$ENV` is `devint`, `qa`, `prod`, etc...

  | name | value | description | sensitive? | source |
  | ---  | ---   | ---         | ---        | ---    |
  | `aad-client-id` | `********` | Client ID of AD Application created | yes | keyvault created by infrastructure deployment for a stage |
  | `app-dev-sp-password` | `********` | Client ID secret of service principal provisioned for application developers | yes | keyvault created by infrastructure deployment for a stage |
  | `app-dev-sp-username` | `********` | Client ID of service principal provisioned for application developers | yes | keyvault created by infrastructure deployment for a stage |

`Azure Target Env - $ENV`

  This group holds the values that are reflected in the naming conventions of all Azure Infrastructure resource names. This is the starting point for targeting a Terraform based Cobalt Infrastructure Template running in the cloud. The source of these values can be found in the Terraform workspace state file per deployment environment of the running instructure. Locally running `Terraform output` in the appropriate workspace is another way to access these values. They can also be found in the key vault account referenced in the state file for any given environment of the release stage.

  > `$ENV` is `devint`, `qa`, `prod`, etc...

  | name | value | description | sensitive? | source |
  | ---  | ---   | ---         | ---        | ---    |
  | `ENVIRONMENT_BASE_NAME_21` | ex `devint-devworkspac-5vjyftn2` | Base resource name | no | ADO - driven from the output of `terraform apply` |
  | `ENVIRONMENT_RG_PREFIX` | ex `devint-devworkspace-5vjyftn2` | Resource group prefix | no | ADO - driven from the output of `terraform apply` |
  | `ENVIRONMENT_SERVICE_PREFIX` | `$(ENVIRONMENT_BASE_NAME_21)-au` | Service prefix | no | ADO - driven from the output of `terraform apply` |
  | `ENVIRONMENT_STORAGE_PREFIX` | ex `devintdevwrksp5vjyftn2` | Storage account prefix | no | ADO - driven from the output of `terraform apply` |
  | `AZURE_DEPLOY_SUBSCRIPTION` | `********` | Subscription to deploy to | yes | ADO |
  | `SERVICE_CONNECTION_NAME` | ex `cobalt-service-principal` | ADO Service Connection name for deployment | no | ADO |

`Azure Service Release - $SERVICE`

  This group holds context about a specific service's project directory structure. It gives you more flexiblity on the type of project structure you choose to use. It also holds variables for deploying a service to a cloud and running service specific integration tests upon release against the cloud service. In the example below, credentials are passed to the settings.xml file.

  > `$SERVICE` is `javahelloworld`, etc...
  > Note: the configuration values here would change based on the service structure and service.

  | name | value | description | sensitive? | source |
  | ---  | ---   | ---         | ---        | ---    |
  | `MAVEN_DEPLOY_GOALS` | ex `azure-webapp:deploy` | Maven goal to deploy application | no | ADO |
  | `MAVEN_DEPLOY_OPTIONS` | ex `--settings $(System.DefaultWorkingDirectory)/drop/provider/javahelloworld-azure/maven/settings.xml -DAZURE_DEPLOY_TENANT=$(AZURE_DEPLOY_TENANT) -DAZURE_DEPLOY_CLIENT_ID=$(AZURE_DEPLOY_CLIENT_ID) -DAZURE_DEPLOY_CLIENT_SECRET=$(AZURE_DEPLOY_CLIENT_SECRET) -Dazure.appservice.resourcegroup=$(AZURE_DEPLOY_RESOURCE_GROUP) -Dazure.appservice.subscription=$(AZURE_DEPLOY_SUBSCRIPTION) -Dazure.appservice.plan=$(AZURE_DEPLOY_APPSERVICE_PLAN) -Dazure.appservice.appname=$(AZURE_HELLOWORLD_SERVICE_NAME)` | Maven options for deployment goal | no | ADO |
  | `MAVEN_DEPLOY_POM_FILE_PATH` | ex `drop/provider/javahelloworld-azure/pom.xml` | Path to `pom.xml` that defines the deploy step | no | ADO |
  | `MAVEN_INTEGRATION_TEST_OPTIONS` | ex `-DINTEGRATION_TESTER=$(INTEGRATION_TESTER) -DAZURE_TESTER_SERVICEPRINCIPAL_SECRET=$(AZURE_TESTER_SERVICEPRINCIPAL_SECRET) -DAZURE_AD_APP_RESOURCE_ID=$(AZURE_AD_APP_RESOURCE_ID)` | Maven options for integration test | no | ADO |
  | `MAVEN_INTEGRATION_TEST_POM_FILE_PATH` | ex `drop/deploy/testing/javahelloworld-test-azure/pom.xml` | Path to `pom.xml` that runs integration tests | no | ADO |
  | `SERVICE_RESOURCE_NAME` | ex `$(AZURE_HELLOWORLD_SERVICE_NAME)` | Name of service | no | ADO |

### Step 4: Deploy the Services

The final step in the process is to execute a service deployment pipeline for each **Maven Service**.
