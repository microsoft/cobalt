
## Containerized Java Function App deployments into Azure via Azure Devops

This document describes how to deploy a **Containerized Java Function App** to Azure in Azure Devops by taking advantage of the **Maven Azure Function Pipeline** staging template.

### Prerequisites

- A running Azure Function App Service deployed from a Cobalt Infrastructure Template.
- A Containerized Java Function App

### Step 1: Prepare project structure

Ensure project files (i.e. `settings.xml`, `Dockerfile`, `pom.xml`) can be found relative to the root directory of your project. In the next step, the devops pipelines needs to be configured to consume these.

    ```bash
    $ tree myjavacontainerapp
    ├───Dockerfile
    ├───pom.xml
    ├───entry_point.yml
    └───maven
    │    ├───settings.xml
    |    └───...
    └───src
          └───main
              ├───...
              └───..
    ```

### Step 2: Configure the Maven Azure Function Pipeline

The starting point of a **Containerized Java Function App** deployment will begin with a `yaml` file within the same project. This starting point passes values to the **Maven Azure Function Pipeline** and should be configured in Azure DevOps. More instructions on Azure Devops configuration can be found [here](https://docs.microsoft.com/en-us/azure/devops/pipelines/get-started/pipelines-get-started?view=azure-devops#define-pipelines-using-yaml-syntax). Here is what the starting point of a **Containerized Java Function App** pipeline might look like:

```yaml
# Omitting PR and Trigger blocks...
variables:
    - group: 'Azure - Common'

    - name: MAVEN_SETTINGS      # Relative path to the settings.xml file.
      value: './myjavacontainerapp/maven/settings.xml'

    - name: DOCKERFILE          # Relative path to the Docker File.
      value: './myjavacontainerapp/Dockerfile'

    - name: POM_FILE            # Relative path to the POM File.
      value: './myjavacontainerapp/pom.xml'

    - name: IMAGE_NAME          # Determines name of the Docker image.
      value: 'java-container-application'

    - name: DOCKER_BUILD_ARGS   # Docker build task arguments
      value: 'VSTS_FEED_TOKEN=$(VSTS_FEED_TOKEN)' # This example passes optional build credentials.

resources:
    repositories:
      - repository: cobalt
        type: git
        name: <<$AZURE_DEVOPS_HOST_PROJECT_NAME>>/cobalt

stages:
- template: devops/providers/azure-devops/templates/function_app_maven/stages.yml
  parameters:
    environments:
    - name: 'devint'

    - ${{ if eq(variables['Build.SourceBranchName'], 'master') }}: # This example executes qa and prod release steps when committing to master
        - name: 'qa'
        - name: 'prod'
```

  **Required Configurations**

  - `repositories` keyword mapping: This is the syntax needed to reference an external repository. The **Maven Azure Function Pipeline** templates live in the infrastructure repository and not in the client app repository with the **Containerized Java Function App**.
  - `template` attribute keyword: This is the syntax needed to use another `yaml` file as a template. The `yaml` file being referenced must be the full path to the staging `yaml` file.
  - `environments` stanza: This impacts the variable groups that are required for the pipeline. This controls which environment the application will be deployed to. It should map to the environments configured in the infrastructure pipeline. In the example shown here, the environments deployed will depend on whether or not the build has been triggered from the `master` branch. This enables non-master builds to deploy only to `devint`.
  - `MAVEN_SETTINGS` variable: 'Use this variable to pass the path to your settings.xml file.
  - `POM_FILE` variable: 'Use this variable to pass the path to your pom file.
  - `DOCKERFILE` variable: Use this parameter to pass the path to your Docker file.
  - `IMAGE_NAME` variable: Use this parameter to give a name to your application docker image.

  **Optional Configurations**

  - `DOCKER_BUILD_ARGS` variable: Arguments for the Docker build command.

### Step 3: Configure the Azure DevOps Variable Groups

Variable groups are named in a way that allows the **Maven Azure Function Pipeline** to target release stage environments. The following tables describe the variable group names required to support a **Containerized Java Function App** deployment. The value columns provide concrete examples for how one might satisfy the variables in each group.

`Azure - Common`

  This values in this group are mainly driven by the `Azure Target Env - $ENV` variable groups. They support a multi-environment pipeline.

  | name | value | description | sensitive? | source |
  | ---  | ---   | ---         | ---        | ---    |
  | `AGENT_POOL` | `Hosted Ubuntu 1604` | Agent on which to run release | no | ADO |
  | `RESOURCE_GROUP_NAME` | `$(ENVIRONMENT_RG_PREFIX)-$(PREFIX_BASE)-app-rg` | Resource group in which the App Service Plan lives | no | ADO - see `Azure Target Env - $ENV` |
  | `FUNCTION_APP_NAME` | `$(ENVIRONMENT_BASE_NAME_21)-myazurefunction` | Tenant linked to subscription.| yes | ADO - see `Azure Target Env - $ENV` |
  | `CONTAINER_REGISTRY_NAME` | `$(ENVIRONMENT_STORAGE_PREFIX)cr` | ACR name for holding jar files as an image | no | ADO - see `Azure Target Env - $ENV` |
  | `PREFIX_BASE` | ex. `organization-name` | Prechosen prefix created by infrastructure deployment | no |  ADO |
  | `SERVICE_CONNECTION_NAME` | ex `cobalt-service-principal` | Default ADO Service Connection name for deployment | no | ADO |

`Azure Target Env - $ENV`

  This is the starting point for targeting a Terraform based Cobalt Infrastructure Template running in the cloud. This group holds the values that are reflected in the naming conventions of all Azure infrastructure resource names. The source of these values can be found in the Terraform workspace state file per deployment environment of the running instructure. Locally running `Terraform output` in the appropriate workspace is another way to access these values.

  > `$ENV` is `devint`, `qa`, `prod`, etc...

  | name | value | description | sensitive? | source |
  | ---  | ---   | ---         | ---        | ---    |
  | `ENVIRONMENT_BASE_NAME_21` | ex `devint-devworkspac-5vjyftn2` | Base resource name | no | ADO - driven from the output of `terraform apply` |
  | `ENVIRONMENT_RG_PREFIX` | ex `devint-devworkspace-5vjyftn2` | Resource group prefix | no | ADO - driven from the output of `terraform apply` |
  | `ENVIRONMENT_STORAGE_PREFIX` | ex `devintdevwrksp5vjyftn2` | Storage account prefix | no | ADO - driven from the output of `terraform apply` |
  | `SERVICE_CONNECTION_NAME` | ex `cobalt-service-principal` | ADO Service Connection name override for deployment stage. | no | ADO |

### Step 4: Deploy the Containerized Java Function App

The final step in the process is to execute the **Maven Azure Function Pipeline** from the **Containerized Java Function App**.
