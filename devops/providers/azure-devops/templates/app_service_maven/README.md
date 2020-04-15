# CICD Maven Service Pipeline Bootstrap Templates

These YAML templates are designed to be included in individual service repositories, configured through Azure DevOps as the primary Build pipeline. The bootstrap delegates the pipeline implementation back to a shared YAML `app_service_maven` pipeline defined in devops/providers/azure-devops/templates/app_service_maven/examples/maven_service_usage_example.yml

## Maven service deployment into Azure via Azure DevOps

This document describes how to deploy a maven service to Azure by taking advantage of the `app_service_maven` shareable build and release templates that can be re-used across maven services.

### Prerequisites
 - Appropriate reference architecture for your infrastructure use case has been deployed

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
 - Stanza which defines the `serviceName`. This controls the name of the service. It should be unique for each service being deployed.

This pipeline will need to be configured in Azure DevOps. The instructions to do this can be found [here](https://docs.microsoft.com/en-us/azure/devops/pipelines/get-started/pipelines-get-started?view=azure-devops#define-pipelines-using-yaml-syntax).

### Step 2: Configure the Azure DevOps Variable Groups

The following table describes the variable groups required to support this service deployment:

`Azure Common Secrets`

| name | value | description | sensitive? | source |
| ---  | ---   | ---         | ---        | ---    |
| `vsts-feed-token` | `********` | Personal Access Token that grants access to the maven repository` | yes | keyvault |

`Azure - Common`

| name | value | description | sensitive? | source |
| ---  | ---   | ---         | ---        | ---    |
| `AGENT_POOL` | `Hosted Ubuntu 1604` | Agent on which to run release | no | ADO | (yaml: yes)
| `AZURE_AD_APP_RESOURCE_ID` | `$(aad-client-id)` | see `aad-client-id` | yes | ADO | (yaml: no, tf output )
| `AZURE_DEPLOY_APPSERVICE_PLAN` | `$(ENVIRONMENT_RG_PREFIX)-$(PREFIX_BASE)-sp` | App Service Plan in which App Service lives | no | ADO | (yaml: composite/mixed var group , tf output )
| `AZURE_DEPLOY_CLIENT_ID` | `********` | Client ID used to deploy to Azure | yes | ADO | (yaml:  )
| `AZURE_DEPLOY_CLIENT_SECRET` | `********` | Client secret for `AZURE_DEPLOY_CLIENT_ID` | yes | ADO | (yaml:  maven xml)
| `AZURE_DEPLOY_RESOURCE_GROUP` | `$(ENVIRONMENT_RG_PREFIX)-$(PREFIX_BASE)-app-rg` | Resource group in which App Service Plan lives | no | ADO | (yaml: composite/mixed var group , tf output )
| `AZURE_DEPLOY_TENANT` | `********` | Tenant linked to subscription | yes | ADO | (yaml: maven xml )
| `AZURE_TESTER_SERVICEPRINCIPAL_SECRET` | `$(app-dev-sp-password)` | See `app-dev-sp-password` | yes | ADO | (yaml: no, used in integration tests,  tf output )
| `AZURE_HELLOWORLD_SERVICE_NAME` | `$(ENVIRONMENT_SERVICE_PREFIX)-helloworld` | Name of App Service for helloworld | no | ADO |
| `CONTAINER_REGISTRY_NAME` | `$(ENVIRONMENT_STORAGE_PREFIX)cr` | ACR name | no | ADO | (yaml: both, tf output and yaml )
| `DEPLOY_ENV` | `empty` | Deployment environment | no | ADO | (yaml: storage maven )
| `DOMAIN` | `contoso.com` | Domain name | no | ADO | ( environment var in test )
| `EXPIRED_TOKEN` | `********` | An expired JWT token | yes | ADO | (yaml:  entitlements test )
| `HELLOWORLD_URL` | `https://$(AZURE_LEGAL_SERVICE_NAME).azurewebsites.net/` | Endpoint for legal service | no | ADO |
| `INTEGRATION_TESTER` | `$(app-dev-sp-username)` | See `app-dev-sp-username` | yes | ADO | (yaml: no, used in tests )
| `PREFIX_BASE` | ex. `organization-name` | . | no | ADO |
| `RESOURCE_GROUP_NAME` | `$(ENVIRONMENT_RG_PREFIX)-$(PREFIX_BASE)-app-rg` | Resource group for deployments | no | ADO | (tf output  )
| `VSTS_FEED_TOKEN` | `$(vsts-feed-token)` | See `vsts-feed-token` | yes | ADO |
| `SERVICE_CONNECTION_NAME` | ex `cobalt-service-principal` | Default service connection name for deployment | no | ADO | (yaml: yes )

`Azure Target Env Secrets - $ENV`
> `$ENV` is `devint`, `qa`, `prod`, etc...

| name | value | description | sensitive? | source |
| ---  | ---   | ---         | ---        | ---    |
| `aad-client-id` | `********` | Client ID of AD Application created | yes | keyvault created by infrastructure deployment for the stage |
| `app-dev-sp-password` | `********` | Client ID secret of service principal provisioned for application developers | yes | keyvault created by infrastructure deployment for stage |
| `app-dev-sp-username` | `********` | Client ID of service principal provisioned for application developers | yes | keyvault created by infrastructure deployment for stage |
| `appinsights-key` | `********` | Key for app insights created | yes | keyvault created by infrastructure deployment for stage |
| `cosmos-connection` | `********` | Connection string for cosmos account created | yes | keyvault created by infrastructure deployment for stage |
| `cosmos-endpoint` | `********` | Endpoint for cosmos account created | yes | keyvault created by infrastructure deployment for stage |
| `cosmos-primary-key` | `********` | Primary key for cosmos account created | yes | keyvault created by infrastructure deployment for stage |
| `storage-account-key` | `********` | Key for storage account created | yes | keyvault created by infrastructure deployment for stage |
| `elastic-endpoint` | `********` | Endpoint of elasticsearch cluster created | yes | keyvault created by infrastructure deployment for stage |
| `elastic-password` | `********` | Password for elasticsearch cluster created | yes | keyvault created by infrastructure deployment for stage |
| `elastic-username` | `********` | Username for elasticsearch cluster created | yes | keyvault created by infrastructure deployment for stage |

`Azure Target Env - $ENV`
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
> `$SERVICE` is `javahelloworld`, etc...
> Note: the configuration values here would change based on the service being deployed. Read them carefully!

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
