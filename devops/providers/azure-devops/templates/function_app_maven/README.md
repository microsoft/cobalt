# Maven Azure Function Pipeline - CICD Bootstrap Templates

These YAML templates are designed to handle the build and deploy steps for a serverless Maven based application in Azure. This can be achieved by consuming the template in the application repository as exemplified by `devops/providers/azure-devops/templates/function_app_maven/examples/maven_function_app_usage_example.yml`

## Prerequisites

- Experience with [Azure Pipelines](https://docs.microsoft.com/en-us/azure/devops/pipelines/get-started/key-pipelines-concepts?view=azure-devops) and [YAML templates](https://docs.microsoft.com/en-us/azure/devops/pipelines/yaml-schema?view=azure-devops&tabs=schema%2Cparameter-schema)
- Familiar with the term **CI/CD** (“Continuous Integration / Continuous Deployment”)
- Understand that our use of the term **Containerized Java Function App** is a scenario where a Maven built Java application is running as a container within an Azure Function.

## What is the Maven Azure Function Pipeline?

In order to simplify **CI/CD** configurations for a **Containerized Java Function App**, a **CI/CD** workflow is being orchestrated by a single `yaml` file. This workflow is the **Maven Azure Function Pipeline**. To kick off this workflow, the Containerized Java Function App passes it's pipeline variable groups, important file paths and declared environments to the pipeline. The pipeline then takes advantage of maven `yaml` and docker `yaml` tasks to test the application, build an application container image and push the image to the targeted Azure Function. In this implementation, the Maven Azure Function Pipeline is hosted in the Cobalt repo but the client application that kicks off the workflow should live in it's own repository.

- ### Maven Azure Function Pipeline

    The diagram below shows the CI/CD workflow topology needed by our enterprise customers to deploy a Containerized Java Function App to running infrastructure in Azure using the Maven Azure Function Pipeline.

    ![Maven Azure Function Pipeline CI/CD WORKFLOW](./.images/CICD_Maven_Azure_Function_Pipeline_v1.png)

- ### YAML features

    - **[stages.yml](./stages.yml)**

        Validates that the **Containerized Java Function App** can build once and then executes a series of release tasks per environment. Environments are passed directly to it from a starting point `yaml` file that is hosted in the client application repo.

        | primary features | `yaml` file | behavior |
        | ---  | ---   | ---  |
        | [Unit Tests](https://docs.microsoft.com/en-us/azure/devops/pipelines/tasks/build/maven?view=azure-devops) | `maven-test.yml` | Automatically detects and runs unit tests using maven tasks. |
        | [Docker Build](https://docs.microsoft.com/en-us/azure/devops/pipelines/tasks/build/docker?view=azure-devops) | `docker-build.yml` | Builds a Docker file and saves it as tar file in the stage directory. |
        | Environment Based Deployments  | `stages.yml` | This file enables release tasks to run per environment. |
        | [ACR Push](https://docs.microsoft.com/en-us/azure/devops/pipelines/tasks/deploy/azure-cli?view=azure-devops)| `acr-push.yml` | Pushes a tar file as an image with an environment tag to an Azure Container Registry. |
        | [Deploy Container Image](https://docs.microsoft.com/en-us/azure/devops/pipelines/tasks/deploy/azure-cli?view=azure-devops) | `function-deploy.yml` | Deploys ACR image to an Azure Function app |

    
    > The pull request and branching strategy in the diagram above is possible by configuring the PR and Trigger blocks highlighted in the [maven function app usage example](./examples/maven_function_app_usage_example.yml).

- ### Variable group naming conventions

    Variable groups are named in a way that allows the pipeline to infer rather or not the group belongs to a specific environment within the release stage. Variable group naming conventions should be respected. They are hardcoded in the following `yaml` files and are required. More details about the values of these variable groups are described in the [app usage](./examples/function_app_usage.md) example.

    | Variable Group | YAML FILE |
    | ---      | ---         |
    |  `Azure - Common` | starting point yaml |
    |  `Azure Target Env - ${{ environment }}` | stages.yml |

- ### Environment boundaries

   The release/cd stage of the **Maven Azure Function Pipeline** cycles through a list of environments provided to it. Environments are properly defined by creating an Azure Devops variable group with the environment naming convention (i.e. `Azure Target Env - ${{ environment }}`). The variable group should hold values needed to for the client application to target a Function App Service currently running from a previous Cobalt Infrastructure Template deployment.

## Next Steps

You may want to try using the **Maven Azure Function Pipeline** to deploy a **Containerized Java Function App** of your own to the Azure cloud by following the [Maven Azure Function Deployment](./examples/function_app_usage.md) usage document!