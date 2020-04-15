## Maven service deployments into Azure via Azure DevOps

This document describes how to deploy a maven service to Azure in Azure Devops by taking advantage of the `app_service_maven` shareable build and release templates that can be re-used across maven services.

### Prerequisites

- Appropriate Cobalt reference architecture for your infrastructure use case has been deployed

### Step 1: Configure the devops pipelines

Services will typically leverage the following common templates to configure their build and release stages:

- `devops/providers/azure-devops/templates/app_service_maven/build-stage.yml`
- `devops/providers/azure-devops/templates/app_service_maven/deploy-stages.yml`

This pipeline will live in the service repository. Here is what one such pipeline might look like:

```yaml
# Omitting PR and Trigger blocks...

variables:
  - group: 'Azure Common Secrets'
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
      copyFileContentsToFlatten: ''
      mavenOptions: '--settings ./maven/settings.xml -DVSTS_FEED_TOKEN=$(VSTS_FEED_TOKEN)'
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

There are some key areas that are worthwhile to understand, as it will impact the variable groups that are required when defining the variable groups:

- Stanza which defines the `environments`. This controls where the application will be deployed to. It should match the environments configured in the infrastructure pipeline. In the example shown here, the environments deployed will depend on whether or not the build has been triggered from the `master` branch. This enables PR builds to deploy only to `devint`.
- Stanza which defines the `serviceName`. This controls the name of the maven service being deployed. It should be unique for each maven service being deployed.

This pipeline will need to be configured in Azure DevOps. The instructions to do this can be found [here](https://docs.microsoft.com/en-us/azure/devops/pipelines/get-started/pipelines-get-started?view=azure-devops#define-pipelines-using-yaml-syntax).

### Step 2: Configure the Azure DevOps Variable Groups

Variable groups are named in a way that allows the pipeline to infer rather or not the group belongs to a specific cloud provider and for which stage should the group be used for. The following table describes the variable groups required to support a service deployment:

`Azure Common Secrets`

  This group holds values within a single key vault account for all stages of the pipeline. This key vault account must be created manually. The infrastructure deployment does not create this key vault account.

  | name | value | description | sensitive? | source |
  | ---  | ---   | ---         | ---        | ---    |
  | `vsts-feed-token` | `********` | Personal Access Token that grants access to a shared maven repository location in Azure Devops` | yes | keyvault |

`Azure - Common`

  This group depends on all the above mentioned variable groups. It also holds the majority of variables needed to deploy a maven service.

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
  | `AZURE_HELLOWORLD_SERVICE_NAME` | `$(ENVIRONMENT_SERVICE_PREFIX)-helloworld` | Name of App Service for helloworld | no | ADO - see `Azure Target Env - $ENV` |
  | `CONTAINER_REGISTRY_NAME` | `$(ENVIRONMENT_STORAGE_PREFIX)cr` | ACR name | no | ADO - see `Azure Target Env - $ENV`  |
  | `HELLOWORLD_URL` | `https://$(AZURE_HELLOWORLD_SERVICE_NAME).azurewebsites.net/` | Endpoint for java helloworld service | no | ADO |
  | `INTEGRATION_TESTER` | `$(app-dev-sp-username)` | see `app-dev-sp-username` | yes | ADO - see `Azure Target Env Secrets - $ENV` |
  | `PREFIX_BASE` | ex. `organization-name` | A unique identifier chosen as a prefix in your infrastructure deployment | no |  ADO - see `Azure Target Env - $ENV` |
  | `RESOURCE_GROUP_NAME` | `$(ENVIRONMENT_RG_PREFIX)-$(PREFIX_BASE)-app-rg` | Resource group for deployments | no | ADO - see `Azure Target Env - $ENV` |
  | `VSTS_FEED_TOKEN` | `$(vsts-feed-token)` | see `vsts-feed-token` | yes | ADO - see `Azure Common Secrets` |
  | `SERVICE_CONNECTION_NAME` | ex `cobalt-service-principal` | Default ADO service connection name for deployment | no | ADO |

`Azure Target Env Secrets - $ENV`

  This group holds the key vault `secret names` a service deployment stage will use to access key vault `secret values` held within a key vault account. The Azure Service Principal used to deploy the infrastructure must be granted Key Management Operations.

  > `$ENV` is `devint`, `qa`, `prod`, etc...

  | name | value | description | sensitive? | source |
  | ---  | ---   | ---         | ---        | ---    |
  | `aad-client-id` | `********` | Client ID of AD Application created | yes | keyvault created by infrastructure deployment for a stage |
  | `app-dev-sp-password` | `********` | Client ID secret of service principal provisioned for application developers | yes | keyvault created by infrastructure deployment for a stage |
  | `app-dev-sp-username` | `********` | Client ID of service principal provisioned for application developers | yes | keyvault created by infrastructure deployment for a stage |
  | `appinsights-key` | `********` | Key for app insights created | yes | keyvault created by infrastructure deployment for a stage |
  | `cosmos-connection` | `********` | Connection string for cosmos account created | yes | keyvault created by infrastructure deployment for a stage |
  | `cosmos-endpoint` | `********` | Endpoint for cosmos account created | yes | keyvault created by infrastructure deployment for a stage |
  | `cosmos-primary-key` | `********` | Primary key for cosmos account created | yes | keyvault created by infrastructure deployment for a stage |
  | `storage-account-key` | `********` | Key for storage account created | yes | keyvault created by infrastructure deployment for a stage |
  | `elastic-endpoint` | `********` | Endpoint of elasticsearch cluster created | yes | keyvault created by infrastructure deployment for a stage |
  | `elastic-password` | `********` | Password for elasticsearch cluster created | yes | keyvault created by infrastructure deployment for a stage |
  | `elastic-username` | `********` | Username for elasticsearch cluster created | yes | keyvault created by infrastructure deployment for a stage |

`Azure Target Env - $ENV`

  This group holds the values that are reflected in the naming conventions of all Azure Infrastructure resource names. The source of these values can be found in the Terraform workspace state file per deployment stage of the running instructure. Running `Terraform output` in the appropriate workspace is another way to access these files. They can also be found in the key vault account referenced in the state file, in this case, it would be the state file and key vault account for the `devint` stage.

  > `$ENV` is `devint`, `qa`, `prod`, etc...

  | name | value | description | sensitive? | source |
  | ---  | ---   | ---         | ---        | ---    |
  | `ENVIRONMENT_BASE_NAME_21` | ex: `devint-devworkspac-5vjyftn2` | Base resource name | no | ADO - driven from the output of `terraform apply` |
  | `ENVIRONMENT_RG_PREFIX` | ex: `devint-devworkspace-5vjyftn2` | Resource group prefix | no | ADO - driven from the output of `terraform apply` |
  | `ENVIRONMENT_SERVICE_PREFIX` | `$(ENVIRONMENT_BASE_NAME_21)-au` | Service prefix | no | ADO - driven from the output of `terraform apply` |
  | `ENVIRONMENT_STORAGE_PREFIX` | ex: `devintdevwrksp5vjyftn2` | Storage account prefix | no | ADO - driven from the output of `terraform apply` |
  | `AZURE_DEPLOY_SUBSCRIPTION` | `********` | Subscription to deploy to | yes | ADO |
  | `SERVICE_CONNECTION_NAME` | ex `cobalt-service-principal` | Service connection name for deployment | no | ADO |

`Azure Service Release - $SERVICE`

  This group holds context about a specific service's project directory structure. It gives you the flexiblity to have more than one type of project structure. It also holds data for deploying a service and running service specific integration tests upon release.

  > `$SERVICE` is `javahelloworld`, etc...
  > Note: the configuration values here would change based on the service structure being deployed.

  | name | value | description | sensitive? | source |
  | ---  | ---   | ---         | ---        | ---    |
  | `MAVEN_DEPLOY_GOALS` | ex `azure-webapp:deploy` | Maven goal to deploy application | no | ADO |
  | `MAVEN_DEPLOY_OPTIONS` | ex `--settings $(System.DefaultWorkingDirectory)/drop/provider/javahelloworld-azure/maven/settings.xml -DAZURE_DEPLOY_TENANT=$(AZURE_DEPLOY_TENANT) -DAZURE_DEPLOY_CLIENT_ID=$(AZURE_DEPLOY_CLIENT_ID) -DAZURE_DEPLOY_CLIENT_SECRET=$(AZURE_DEPLOY_CLIENT_SECRET) -Dazure.appservice.resourcegroup=$(AZURE_DEPLOY_RESOURCE_GROUP) -Dazure.appservice.plan=$(AZURE_DEPLOY_APPSERVICE_PLAN) -Dazure.appservice.appname=$(AZURE_HELLOWORLD_SERVICE_NAME) -Dazure.appservice.subscription=$(AZURE_DEPLOY_SUBSCRIPTION)` | Maven options for deployment goal | no | ADO |
  | `MAVEN_DEPLOY_POM_FILE_PATH` | ex `drop/provider/javahelloworld/pom.xml` | Path to `pom.xml` that defines the deploy step | no | ADO |
  | `MAVEN_INTEGRATION_TEST_OPTIONS` | ex `-DINTEGRATION_TESTER=$(INTEGRATION_TESTER) -DHOST_URL=$(HELLOWORLD_URL) -DMY_TENANT=$(MY_TENANT) -DAZURE_TESTER_SERVICEPRINCIPAL_SECRET=$(AZURE_TESTER_SERVICEPRINCIPAL_SECRET) -DAZURE_AD_TENANT_ID=$(AZURE_DEPLOY_TENANT) -DAZURE_AD_APP_RESOURCE_ID=$(AZURE_AD_APP_RESOURCE_ID)` | Maven option for integration test | no | ADO |
  | `MAVEN_INTEGRATION_TEST_POM_FILE_PATH` | ex `drop/deploy/testing/javahelloworld-test-azure/pom.xml` | Path to `pom.xml` that runs integration tests | no | ADO |
  | `SERVICE_RESOURCE_NAME` | ex: `$(AZURE_HELLOWORLD_SERVICE_NAME)` | Name of service | no | ADO |

### Step 3: Deploy the Services

The final step in the process is to execute the deployment pipelines.
