# Bootstrap for Cobalt IaC Pipelines on Azure DevOps

## Overview 
This provides a starting point for anyone interested in having an Azure DevOps
Project that will 'run' a target Cobalt template whenever that template changes.

## Intended audience

This article is for an infrastructure worker that is brand new to Cobalt templating, and it's *Cobalt Infrastructure 
Template* (CIT) developer workflow, who wants to stand-up Azure DevOps and Azure resources to enact a CI/CD process
over their infrastructure as code work.

### An example
Imagine that you are building a new set of web applications which are destined
to run on Azure. Those applications are going to use a few runtime resources, and you've
wisely decided to use a Cobalt template to satisfy and centralize your Infrastructure as Code ("IaC") 
needs across all of those applications. 

To get started, you want a central Git repository to store your IaC in, 
and following [solid engineering fundamentals](https://github.com/microsoft/code-with-engineering-playbook/tree/master/continuous-integration#continuous-integration),
you've decided to wrap CI/CD, and staged deployments around your IaC to help
protect the quality of your infrastructure changes.

This bootstrap (itself a Cobalt template) can be used to quickly, safely, and easily create 
the ADO resources (a Project, Git Repository, Build Definitions, Variable Groups, 
Service Connections, etc) that you'll need in that example.

### Terminology
Given that we're using a Cobalt template to create resources that will then operate other
Cobalt templates, discussing matters can become a bit confusing. To help with that, and 
to get specific about a few other terms we'll use, let's define a few terms and then use
them consistently, within this document and this bootstrap template itself.

|Term|Meaning|
|----|----|
|ADO|Azure DevOps, AKA "AzDO," elsewhere|
|Application(s)|The application that will rely on the resources managed by the Infrastructure Template|
|Bootstrap Template|This Cobalt template, as described in the example, above|
|IaC|Infrastructure as Code|
|Infrastructure Template|Whichever Cobalt template that will manage the Application(s) runtime resources. _By default, the Bootstrap Template points to the 'Hello World' example template in the official Cobalt GitHub repository_|
|Project|The ADO Project that the Bootstrap Template will add pipeline resources to|
|IaC Repository|(empty) Git Repository in the Project where the Infrastructure Template is expected to be kept|

## What the Bootstrap Template needs, provisions, and outputs

To work properly, the Bootstrap Template needs some information about how you want things named, how many environments
are desired (and their details), and little else. The template also creates many kinds of resources

### Decide with Project to use

Visit your ADO Organization site and select or create a project. This project will house the pipelines that
will operate your IaC CI/CD pipelines. Note that project's name. We'll need to use it as an input, in the next section.

### Inputs

There are two places from where the template consumes input information. 
    1. The environment variables that are set before the template is used-- usually these are `export` shell environment variables. 
    2. The other is a `terraform.tfvars` file. 
    
Let's quickly explore each of these. 

#### Environment Variable

You'll need to define a `.env` file in the root of the project. 

You can use our environment template file to start with: `cp .env.template .env`

Provide values for the environment values in `.env` which are required to allow 
Terraform to provision resources within your subscription, and your Azure DevOps Organization.

```bash
ARM_SUBSCRIPTION_ID="<az-service-principal-subscription-id>"
ARM_CLIENT_ID="<az-service-principal-client-id>"
ARM_CLIENT_SECRET="<az-service-principal-auth-secret>"
ARM_TENANT_ID="<az-service-principal-tenant>"
ARM_ACCESS_KEY="<remote-state-storage-account-primary-key>"
AZDO_PERSONAL_ACCESS_TOKEN="<see, below>"
AZDO_ORG_SERVICE_URL="<typically: https://dev.azure.com/__YOUR_ORG__/"
```

_Note: you can find out more information about the Azure DevOps personal access token [here](https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=azure-devops&tabs=preview-page)._

#### Terraform Variables

The Environments and Azure Subscription details, for each, need to be provided in the `terraform.tfvars` file.
It should take the form of:

```hcl-terraform
environments = [{
    environment: "dev1",
    az_sub_id: "1aaaaaa1-bbbb-cccc-dddd-eeeeee"
},{
    environment: "dev2",
    az_sub_id: "4aaaaaa4-bbbb-cccc-dddd-eeeeee"
},{
    environment: "prod",
    az_sub_id: "1aaaaaa1-bbbb-cccc-dddd-eeeeee"
}]
```

In the structure above, you can indicate as many environments as needed. Each should have a unique `environment` value,
and each will need an accurate `az_sub_id`. For each environment, `az_sub_id` is the Azure Subscription ID that the 
Infrastructure Template will eventually provision resources into.

You'll also need to specify the name of the Project (_The ADO Project that the Bootstrap Template will add pipeline resources to_).
The Bootstrap Template can be used with an existing Azure DevOps Project ("the Project"), or it can create
a new project. Take a look at the `azdo.tf` file, around lines 12-34 to see examples of how to use the template
for either choice.

In either case, you'll need to provide the name of the Project to use with a line like this:
```hcl-terraform
project_name = "My CICD Project Name"
```

### Provisioned Resources

The Bootstrap Template creates a few resources in the Azure Subscription(s) and the Azure DevOps Organization that you
pointed to with the inputs, above. These resources establish the CI/CD pipelines in ADO, and map those pipelines to 
the appropriate Azure Subscriptions.

Here's a list of the resources that are provisioned including what a typical name might be, what kind of resource it is,
and some extra detail about the purpose of the resource. 

| Name (typical) | Resource Type | Description |
| --- | --- | --- |
| Infrastructure Pipeline Variables | azuredevops_variable_group | Common values that all pipelines share |
| Infrastructure Pipeline Variables - *prod* | azuredevops_variable_group | Environment-specific values, per pipeline |
| Infrastructure Pipeline Secrets - *prod* | azuredevops_variable_group | Environment-specific secret values, per pipeline |
| Infrastructure Repository | azuredevops_git_repository | The Git repository where Infrastructure templates are stored and watched for changes |
| Infrastructure CICD | azuredevops_build_definition | The Build Definition that watches for IaC Template changes, and then triggers the Infrastructure pipelines |
| Infrastructure Deployment Service Connection | azuredevops_serviceendpoint_azurerm | The service connection that the Infrastructure Template will run under |
| bootstrap-deploy-app | azuread_application | app |
| n/a | azuread_service_principal | The Azure Service Principal that the Infrastructure Template will run under |
| n/a | azurerm_role_assignment | The Azure Service Principal role assignment that the Infrastructure Template will run under |
| bootstrap-iac-tf-workspaces | azurerm_resource_group | The Azure Resource Group which houses the remote state containers for Terraform |
| iactf*prod* | azurerm_storage_account | An Azure Storage Account to house remote state containers, for a given environment |
| tfstate | azurerm_storage_container | The Azure Blob Storage Container, within an environment-specific Azure Storage Account that will house remote state containers for Terraform |
| *project_name* | The ADO Project that the Bootstrap Template will add pipeline resources to |

### Outputs

After the Bootstrap Template has been applied (via `terraforma apply`) you will see some output reflecting the

| name | description |
| ---- | ----------- |
| project_id | The ID of the Project that was provisioned |
| project_name | The name of the Project that was provisioned |
| repo_clone_url | The *https* (not the *ssh*) URL of the IaC Repository that was created |

## Running the Bootstrap Template

### Set-up

For the purposes of this Bootstrap Template, you'll need a few tools to be ready on your workstation.

Please see the quick start guide's list of prerequisites: *[quick-start guide prerequisites](https://github.com/microsoft/cobalt/blob/master/docs/2_QUICK_START_GUIDE.md#2.3-prerequisites).*

Also, please install the ["Terraform Provider for Azure DevOps"](https://github.com/microsoft/terraform-provider-azuredevops) by
following instructions [here](https://github.com/microsoft/terraform-provider-azuredevops#developing-the-provider). 
In particular (as of this writing), you'll need to clone the repository locally, then run these commands:

* Installing the provider
```bash
./scripts/build.sh          # build & test provider code
./scripts/local-install.sh  # install provider locally
```

The goal is to make the _Terraform Provider for Azure DevOps_ available to your local Terraform installation. In the
future, you will not need to install this provider by-hand (because `terraform init` will install it for you, after the
official, initial release of that provider.)

## Example Usage

For this example, we'll be using `bash` running on a unix, such as OSX, Ubuntu or Windows Subsystem for Linux. 

1. Navigate to the directory where the `ado-bootstrap-iac-pipeline` template (where this `README.md` file is at). 

1. Execute the following commands to set the environment variables that the template will require 
for Terraform, Azure and Azure DevOps. This will take the values in an .env file and export them in the local
shell:

```bash
# these commands `export` the environment variables needed to run this template into the local shell
DOT_ENV=<path to your .env file -- see .env.template for more information>
export $(cat $DOT_ENV | xargs)
```

1. Execute the following commands to set up your terraform workspace.

_Note: the Bootstrap Template creates the Azure resources needed for handling Terraform remote state, but
we're not using remote state configuration for this._ 

```bash
# This command configures terraform to use a local workspace unique to you. 
terraform init
```

5. Execute the following commands to orchestrate a deployment.

```bash
# See what terraform will try to deploy without actually deploying
terraform plan
```

Review the output from the `plan` and make sure everything looks right. 

For example, you might want the names of environments, or Resource Groups to be slightly different. 

Also, if you happen to be running the Bootstrap Template
a second time (after a previous `apply` operation), then you'll want to be careful that Terraform isn't removing or
replacing any resources that you didn't intend it to.

When everything looks good, you can let Terraform create everything in the plan:

```bash
# Execute a deployment
terraform apply
```

6. Contribute your Cobalt IaC repo to the newly provisioned Infrastructure Repository.

7. Trigger the Infrastructure CICD pipeline that was provisioned into the Project.

8. Authorize the Infrastructure CICD pipeline to access the variable groups that were provisioned by the into the Project.