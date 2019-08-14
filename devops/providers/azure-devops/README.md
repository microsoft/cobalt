
- [Background Context](#background-context)
- [Setup](#setup)
  - [Prerequisites](#prerequisites)
  - [CI/CD with Azure DevOps using the Azure DevOps CLI](#CI/CD-with-Azure-DevOps-using-the-Azure-DevOps-CLI)
  - [CI/CD with Azure DevOps using the Azure DevOps UI](#CI/CD-with-Azure-DevOps-using-the-Azure-DevOps-UI)
- [Design Motivation](#design-motivation)
  - [CI/CD Flow](#ci/cd-flow)
-[References](#references) 

# Background Context 
This section describes how to configure Azure Devops as the CI/CD system for your DevOPS Workflow.

# Setup 

### Prerequisites

1. _Permissions_: The ability to create Projects in your Azure DevOps Organization.
2. Azure CLI installed on your [machine](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest).

### CI/CD with Azure DevOps using the Azure DevOps CLI 

```bash
az devops project create -n $PROJECT_NAME
```
TODO

### CI/CD with Azure DevOps using the Azure DevOps UI

#### Create a new project

TODO

#### Create a Service Connection to Github

- Within your newly created Azure DevOPS project, create a Github service connection within Settings->Pipelines->Service Connections->Github

![image](https://user-images.githubusercontent.com/7635865/56069523-fc187300-5d48-11e9-8c38-78c2d734332c.png)

- [Authenticate](https://docs.microsoft.com/en-us/azure/devops/boards/github/connect-to-github?view=azure-devops#authentication-options) your Azure DevOPS account to GitHub

#### Add Azure Pipelines Build YAML

- Within your azure devops project, create a new pipeline

![image](https://user-images.githubusercontent.com/7635865/56069362-549b4080-5d48-11e9-97b9-02cb01cc5b35.png)

- Select GitHub as your source

![image](https://user-images.githubusercontent.com/7635865/56069729-05eea600-5d4a-11e9-8aa8-002feb8519a0.png)
Add the [azure-pipelines.yml](./azure-pipelines.yml) file to its root to defines the build rules for your Azure Devops pipeline.

- After selecting your service connection, provide the location of your target repository.

![image](https://user-images.githubusercontent.com/7635865/56069808-5fef6b80-5d4a-11e9-9d5d-d4a7fb372a41.png)

- Point the build definition to the repository's target yaml pipeline location.

![image](https://user-images.githubusercontent.com/7635865/56069873-a5ac3400-5d4a-11e9-80e0-fe2e90b5639b.png)

![image](https://user-images.githubusercontent.com/7635865/56069976-2c611100-5d4b-11e9-9bc0-b4dad6d1cd9c.png)

### Key Vault variable group

Terraform templates are provisioned through a service principal. You'll need to create a keyvault resource that includes the service principal credential secrets listed below.

#### Required Build Pipeline Variables

Setup the below variables to the build pipeline definition.

- `DATACENTER_LOCATION` - The deployment location.
- `ACR_USERNAME` - The ACR username of the base image location.
- `ACR_HOST` - The ACR hostname of the base image location.
- `TF_VAR_remote_state_account` - The terraform remote state storage account name.
- `TF_VAR_remote_state_container` - The terraform remote state storage container name.

# Design Motivation
This section describes how to configure Azure Devops as the CI/CD system for your DevOPS Workflow.

### CI/CD Flow

![cobalt-ci-flow](https://user-images.githubusercontent.com/7635865/56059699-42aaa500-5d2a-11e9-8544-5236e7a9b2ef.png)

# References

- [Azure Pipelines](https://docs.microsoft.com/en-us/azure/devops/pipelines/get-started/what-is-azure-pipelines?toc=/azure/devops/pipelines/toc.json&bc=/azure/devops/boards/pipelines/breadcrumb/toc.json&view=azure-devops)
