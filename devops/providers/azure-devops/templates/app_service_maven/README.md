# Shared Maven Service Pipeline - CICD Bootstrap Templates

These YAML templates are designed to handle the build and deploy steps for Maven based projects. This can be achieved by consuming the template in the application repository as exemplified by `devops/providers/azure-devops/templates/app_service_maven/examples/maven_service_usage_example.yml`

## Prerequisites

- Experience with [Azure Pipelines](https://docs.microsoft.com/en-us/azure/devops/pipelines/get-started/key-pipelines-concepts?view=azure-devops) and [YAML templates](https://docs.microsoft.com/en-us/azure/devops/pipelines/yaml-schema?view=azure-devops&tabs=schema%2Cparameter-schema)
- Familiar with the term “Continuous Integration / Continuous Deployment” ( **CI/CD** )
- Understand that our use of the term **Maven Service** is a scenario where Maven is servicing a Java based application

## What is the Shared Maven Service Pipeline?

In order to further simplify **CI/CD** configurations for a **Maven Service**, common CI/CD operations have been abstracted away into a build `yaml` file and release `yaml` file. These two files orchestrate the **Shared Maven Service Pipeline**. The pipeline executes the CI/CD workflow for one or many Maven Services by exposing input parameters that services can use to pass context. The shared pipeline then passes values to other `yaml` files. The pipeline's ability to pass values from one `yaml` file to another is achieved by taking advantage of the [Azure Devops `yaml` templating feature](https://docs.microsoft.com/en-us/azure/devops/pipelines/yaml-schema?view=azure-devops&tabs=schema%2Cparameter-schema). In this implementation, the Shared Maven Service Pipeline is hosted in the Cobalt repo but each client application that it serves should live in their own respective repos.

- ### Shared Maven Service Pipeline

    The diagram below shows the CI/CD workflow topology needed by our enterprise customers to deploy Maven Services to running infrastructure in Azure using the Shared Maven Service Pipeline.

    ![Shared Maven Service CI/CD WORKFLOW](./.images/CICD_Shared_Maven_Service_Pipeline_v1.png)

- ### YAML features

    - **[build-stage.yml](./build-stage.yml)**

        The `build_stage.yml` validates that the service can build by consuming values passed directly to it from a **Maven Service** `yaml` file. Each service hosts its own `yaml` file and is responsible for passing the correct values.

        | primary features | build stage file | behavior |
        | ---  | ---   | ---  |
        | [Maven Build](https://docs.microsoft.com/en-us/azure/devops/pipelines/tasks/build/maven?view=azure-devops) | `build_stage.yml` | Build application components using maven tasks. |
        | Unit Tests | `build_stage.yml` | Automatically detects and runs unit tests using maven tasks. |
        | Archive Integration tests | `build_stage.yml` | Zips integration tests. |

    - **[deploy-stages.yml](./deploy-stages.yml)**

        Per cloud provider, the `deploy-stage.yml` executes a set of tasks for every environment passed to it from a **Maven Service** `yaml` file. The final task in this file runs integration tests.

        | primary features | deploy stage file | behavior |
        | ---  | ---   | ---  |
        | Cloud Based Deployments | `deploy-stage.yml` | This file enables the deploy steps to run per cloud provider. Our implementation is Azure bound. |
        | Environment Based Deployments  | `deploy-stage.yml` | This file enables the deploy steps to run per a cloud provider's configured list of environments. |
        | Detect App Service Jar File | `app-service-detect-jar.yml` | Scans the incoming artifact drop folder for the jar file. |
        | Publish Jar File Image | `app-service-acr-publish.yml` | Uploads jar file to image container registry. |
        | [Maven Deploy](https://docs.microsoft.com/en-us/azure/devops/pipelines/tasks/build/maven?view=azure-devops) | `app-service-deployment-steps.yml` | Deploy application using maven tasks. |
        | App Service CL Update | `app-service-update-commandline.yml` | Updates the App Service startup command with information about the newly deployed JAR file. |
        | Integration Tests | `app-service-deployment-steps.yml` | Automatically detects and runs integration tests using maven tasks. |

    >  The pull request and branching strategy in the diagram above is possible by configuring the PR and Trigger blocks highlighted in the [maven function app usage example](./examples/maven_function_app_usageexample.yml).

- ### Variable group naming conventions

    Variable groups are named in a way that allows the pipeline to infer rather or not the group belongs to a specific environment within the release stage. Variable group naming conventions should be respected. They are hardcoded and parameterized in the following `yaml` files and are required. More details about the values of these variable groups are described in the [Maven Service Deployments](./examples/service_usage.md) usage documentation.

    | Variable Group | YAML FILE |
    | ---      | ---         |
    |  `Azure - Common` | Service yaml |
    |  `Azure - Common` | deploy-stages.yml |
    |  `${{ provider.name }} Target Env - ${{ environment }}` | deploy-stages.yml |
    |  `${{ provider.name }} Target Env Secrets - ${{ environment }}` | deploy-stages.yml |
    |  `${{ provider.name }} Service Release - ${{ parameters.serviceName }}` | deploy-stages.yml |

- ### Cloud provider and Environment boundaries

    The **Shared Maven Service Pipeline** currently accomodates a multi-cloud **Maven Service** deployment. However, current implementation is Azure bound. Azure bound means that if you have a multi-cloud Maven Service, this pipeline only has an execution workflow targeting Azure infrastructure. The service contracts for other cloud providers are in place but have not been implemented.  In short, deployments to a cloud provider are bound by their `yaml` pipeline configuration, the variable groups that belong to them and whether or not the Maven Service solution includes that cloud provider's implementation.

    When adding a new environment for the release stage, satisfy the `${{ environment }}` parameter in the above variable groups. If implementation details have been introduced for other cloud providers, the `${{ provider.name }}` parameters should be used.

## Next Steps

You may want to try using the **Shared Maven Service Pipeline** to deploy a Maven based java application of your own to the Azure cloud by following the [Maven Service Deployments](./examples/service_usage.md) usage document!
