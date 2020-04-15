# Getting Started - Application Developer - Azure CLI

*Prefer using portals? Follow the [portal-based walkthrough](./GETTING_STARTED_APP_DEV.md).*

## Overview

This section provides application developers wishing to host solutions on Cobalt templates recommendations for building their infrastructure-as-code repository and accompanying CI/CD pipelines. It assumes an isolated Azure DevOps Project with a Cobalt template Repo and Build Pipeline has already been created as defined in the [Getting Started - Advocated Pattern Owner](./GETTING_STARTED_ADD_PAT_OWNER.md) walkthrough.

By creating an application-specific project, you are creating a single project supporting the two main pillars of an application -- the Cobalt-template-based infrastructure and CI/CD build pipeline, and the application code and CI/CD build pipeline. **Important**: as an application developer, you will not be modifying the Cobalt template even though you will be importing all of the required code into your project repository. Instead, you will be responsible only for modifying the configuration via the template's `terraform.tfvars` file to support your application's unique settings (e.g., the number of deployment targets to create or Azure Container Registry image URLs). 

There may be many applications forking from a single governed organization-specific Cobalt template, and requested changes should be made to the source Cobalt template repository so that all applications may update to the latest when needed.

## Prerequisites

* Azure CLI
  * [Get started with Azure CLI](https://docs.microsoft.com/en-us/cli/azure/get-started-with-azure-cli?view=azure-cli-latest)
* Azure DevOps CLI extension
  * [Get started with Azure DevOps CLI](https://docs.microsoft.com/en-us/azure/devops/cli/get-started?view=azure-devops)
* Existing repository and CI/CD pipeline for desired Cobalt template 
  * [Getting Started - Advocated Pattern Owner](./GETTING_STARTED_ADD_PAT_OWNER.md)

## Steps

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
export COBALT_PIPELINE_NAME="Cobalt CICD Pipeline"
```

> NOTE: Before you can run Azure DevOps CLI commands, you need to run the login command (`az login` if using AAD/MSA identity else `az devops login` if using PAT token) to setup credentials. Please see https://aka.ms/azure-devops-cli-auth for more information.

### 2. Setup Azure DevOps Project

Set your organization as the default organization for all subsequent Azure DevOps CLI commands.
```bash
az devops configure -d organization="$DEFAULT_ORGANIZATION"
```

If you already have a project for your application, you may choose to skip this step. If you need to create a new Azure DevOps project, execute the following command.
```bash
az devops project create --name "$APP_DEVOPS_PROJECT_NAME"
```

Whether you are using an existing project or just created one, set your project as the default project for all subsequent Azure DevOps CLI commands.
```bash
az devops configure -d project="$APP_DEVOPS_PROJECT_NAME"
```

### 3. Setup Azure DevOps Repo for Cobalt source

Create a new repository for the Cobalt source within your application project. Import the source from your organizational Cobalt template repository as created in the [Getting Started - Advocated Patterns Owner](./GETTING_STARTED_ADD_PAT_OWNER.md).

```bash
az repos create --name "$APP_DEVOPS_INFRA_REPO_NAME"
az repos import create --git-url $GIT_SOURCE_URL --repository "$APP_DEVOPS_INFRA_REPO_NAME"
```

> NOTE: The `az repos import` command only works with public Git repositories at the time this walkthrough was last updated. If the source template repository is private, you can manually import the source repository. This operation requires a temporary local clone of the private repository. To locally clone the private Git repository, you may need to create a Personal Access Token with permissions to clone. Additionally, if the target repository (within the newly created project) is also private, you may need to create a Personal Access Token with permissions to push to the new repository. For the purposes of this walkthrough, we recommend creating public repositories.
>
> If private repositories are required, the following steps will support the manual process.
> 
> ```bash
> # Set the (new) target repository URL
> GIT_TARGET_URL=$(az repos show -r $APP_DEVOPS_INFRA_REPO_NAME --query webUrl)
> 
> mkdir temprepo
> cd temprepo
> 
> # Clone the private repo to a temp local directory
> git clone --bare $GIT_SOURCE_URL .
> 
> # Copy the source repo to the target repo
> git push --mirror $GIT_TARGET_URL
> 
> # (Optional) If the source repo has LFS objects, fetch and copy to target repo
> # git lfs fetch origin --all
> # git lfs push --all $GIT_TARGET_URL
> 
> # Delete temporary folder with local clone
> cd ..
> rm -rf temprepo
> ```
>
> This approach depends on native Git commands. More information available at the [Microsoft site](https://docs.microsoft.com/en-us/azure/devops/repos/git/import-git-repository?view=azure-devops#manually-import-a-repo), or [Github forking](https://help.github.com/en/articles/fork-a-repo).

### 4. Setup Azure DevOps CI/CD Build Pipeline for Cobalt

Create the build pipeline. We are intentionally skipping the initial run since we know it will fail; we need to link the required variables groups to this pipeline, and currently that cannot be done directly through the Azure DevOps CLI.
```bash
az pipelines create --name "$COBALT_PIPELINE_NAME" --repository "$APP_DEVOPS_INFRA_REPO_NAME" --branch master --repository-type tfsgit --yml-path $APP_DEVOPS_INFRA_YML_PATH --skip-run true
```

Variable groups are utilized by the pipeline to configure how the Cobalt template will be tested and deployed. The latest configuration values are described in the [pipeline documentation](../devops/providers/azure-devops/README.md) and they will need to be configured in order for the CICD pipeline to effectively run.

> **Note**: The following CLI command can be run as an alternative to using the portal-based instructions:

```bash
az pipelines variable-group create --authorize true --name "$VARIABLE_GROUP_NAME" --variables KEY1="VALUE1" ...
```

Within the pipeline build definition you may specify the number of environments that will be targed for deployment. For each environment specified, you will need a variable group that defines the Azure Subscription ID to where the infrastructure will be provisioned. You will also need to set a Service Connection that has permissions to provision resources on that subscription.

For this walkthrough, we will only create a single environment -- *devint*. Follow the documentation linked above and create the necessary variable groups for devint.

> NOTE: The Service Connection name should be provided by someone in your organziation with the *Global administrator* permission for your Azure Active Directory tenant. If it has not been provisisioned for you, you may create another by following the directions outlined in the [Getting Started - Advocated Pattern Onwer documentation](./GETTING_STARTED_ADD_PAT_OWNER.md)

At this time, the Azure DevOps CLI does not support linking variable groups to pipelines. We have a temporary workaround utilizing the Azure DevOps `invoke` command to directly call the Azure DevOps REST API to update the build definition.

Write the current value of the build pipeline definition to a temporary local file, and save the PIPELINE_ID.
```bash
az pipelines show --name "$COBALT_PIPELINE_NAME" -o json > builddef.json
PIPELINE_ID=$(az pipelines show --name "$COBALT_PIPELINE_NAME" --query id)
```

Execute the list command to find the Variable Group IDs. Make note of the IDs as they will need to be added to the build pipeline definition.
```bash
az pipelines variable-group list
```

For the workaround, you'll be manually editing the builddef.json file to add the variable group references. At the end of the file, you should see the line `"variableGroups" : null`. Replace the value with the following, replacing the variable group ID placeholders (`0`) with those from the above command for the Infrastructure Pipeline Variables group and DevInt Environment Variables group:
```bash
  "variableGroups": [
      { "id": 0 },
      { "id": 0 }
  ],
```

Save the file. Use the az devops invoke command to update the pipeline build definition with the linked variable groups.
```bash
az devops invoke --http-method PUT --area build --resource definitions --route-parameters project="$APP_DEVOPS_PROJECT_NAME" definitionId=$PIPELINE_ID --in-file builddef.json
```

### 5. Run and verify

Queue a pipeline to run.
```bash
az pipelines run --name "$COBALT_PIPELINE_NAME"
```

Because you have cloned a pipeline definition that was created from the [Getting Started - Advocated Pattern Owner](./GETTING_STARTED_ADD_PAT_OWNER.md) walkthrough, the pipeline definition may be setup to tear down the infrastructure provisioned. For this step in the end-to-end process, we would like the environment to be durable and persist beyond the pipeline execution. Check the primary `azure-pipelines.yml` file's stages. Verify that the `configurationMatrix` does not include an `environmentsToTeardownAfterRelease` property. If it does, remove it so that the environment remains available for use by the application after the pipeline succeeds. 

To host your application on this provisioned environment, update the `*.tfvars` file specific to your template to ensure your application is being deployed to the infrastructure. You may also need to add values to your provisioned Azure Key Vault resource for the application to work as expected.

## Outcomes

After completing these steps, you should have an Azure DevOps Project for your application that contains:
* An Azure DevOps Repo for your application's Cobalt template infrastructure
* An Azure DevOps Build CI/CD Pipeline for your application's Cobalt template infrastructure including successful deployment and provisioning of template resources
* Provisioned durable resources available in your target Azure Subscription

## Additional Recommendations

We recommend creating a separate repository in the same shared application project for your application code. Additionally, an application CI / CD build pipeline should be created to manage the application -- executing tests, building a container, and deploying the container to the Cobalt-provisioned Azure Container Registry. The application project would then have two pillars -- one supporting the Cobalt template infrastructure configuration specific to the application, and one supporting the application development.
