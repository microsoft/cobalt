# Bootstrap for Cobalt IaC Pipelines on Azure DevOps

## Overview 
This provides a starting point for anyone interested in having an Azure DevOps
Project that will 'run' a target Cobalt template whenever that template changes.

## Intended audience

*FIXME:* Application developer that is brand new to Cobalt templating and it's *Cobalt Infrastructure Template* (CIT) developer workflow.

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

*FIXME:* during final edits, make sure this list is concise and sufficient.

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

### Provisioned Resources

The Bootstrap Template creates a few resources in the Azure Subscription(s) and the Azure DevOps Organization that you
pointed to with the inputs, above. These resources establish the CI/CD pipelines in ADO, and map those pipelines to 
the appropriate Azure Subscriptions.

Here's a list of the resources that are provisioned including what a typical name might be, what kind of resource it is,
and some extra detail about the purpose of the resource. 

| Name (typical) | Resource Type | Description |
| --- | --- | --- |
| Infrastructure Pipeline Variables | azuredevops_variable_group | core_vg |
| *prod* Environment Variables | azuredevops_variable_group | stage_vg |
| Infrastructure Repository | azuredevops_git_repository | repo |
| Infrastructure CICD | azuredevops_build_definition | build |
| Infrastructure Deployment Service Connection | azuredevops_serviceendpoint_azurerm | endpointazure |
| cobalt-deploy-app | azuread_application | app |
| n/a | azuread_service_principal | sp |
| n/a | azurerm_role_assignment | rbac |
| *f6ak7j16fg48* | random_string | random |
| *XCfV#{O16&42FjD* | azuread_service_principal_password | passwd |
| cobalt-iac-tf-workspaces | azurerm_resource_group | rg |
| iactf*prod* | azurerm_storage_account | acct |
| tfstate | azurerm_storage_container | container |

### Outputs

After the Bootstrap Template has been applied (via `terraforma apply`) you will see some output reflecting the

| name | description |
| ---- | ----------- |
| project_id | The ID of the Project that was created |
| project_name | The name of the Project that was created |
| repo_clone_url | The *https* (not the *ssh*) URL of the IaC Repository that was created |

## Running the Bootstrap Template

### Set-up

For the purposes of this Bootstrap Template, you'll need a few tools to be ready on your workstation.

Please see the quick start guide's list of prerequisites: *[quick-start guide prerequisites](https://github.com/microsoft/cobalt/blob/master/docs/2_QUICK_START_GUIDE.md#2.3-prerequisites).*

## Example Usage

For this example, we'll be using `bash` running on a unix, such as OSX, Ubuntu or Windows Subsystem for Linux. 

1. Navigate to the directory where the `ado-bootstrap-iac-pipeline` template (where this `README.md` file is at). 

1. Execute the following commands to set the environment variables that the template will require 
for Terraform, Azure and Azure DevOps:

```bash
# these commands `export` the environment variables needed to run this template into the local shell
DOT_ENV=<path to your .env file -- see .env.template for more information>
export $(cat $DOT_ENV | xargs)
```

1. Execute the following command to configure your local Azure CLI. 
**Note**: This is a temporary measure until we are able to break the dependency on the Azure CLI. 
This work is being tracked as a part of [Issue 153](https://github.com/microsoft/cobalt/issues/153)

```bash
# This logs your local Azure CLI in using the configured service principal.
az login --service-principal -u "$ARM_CLIENT_ID" -p "$ARM_CLIENT_SECRET" --tenant "$ARM_TENANT_ID"
```

1. Execute the following commands to set up your terraform workspace.

_Note: the Bootstrap Template creates the Azure resources needed for handling Terraform remote state, thus
we will not be running Terraform, here, with a remote state configuration._ 

```bash
# This command configures terraform to use a local workspace unique to you. 
terraform workspace new $USER || terraform workspace select $USER
terraform init
```

5. Execute the following commands to orchestrate a deployment.

```bash
# See what terraform will try to deploy without actually deploying
terraform plan
```

Review the output from the `plan` and make sure that everything looks right. 

For example, you might want the names of environments, or Resource Groups to be slightly different. 

Also, if you happen to be running the Bootstrap Template
a second time (after a previous `apply` operation), then you'l want to be careful that Terraform isn't removing or
replacing any resources that you didn't intend it to.

When everything looks good, you can let Terraform create everything in the plan:

```bash
# Execute a deployment
terraform apply
```

## Temporary
That pipeline is defined by a YAML file expected to be found in the Infrastructure Template. The pipeline runs under 

## Todos
- [ ] describe all `variables` and `outputs`
- [ ] describe the AZ resources generated
- [ ] provide some in-line doc for the `.tf`
- [ ] write step-by-step guide
- [ ] audit/fix the variable groups that are being created

---


#### Required Variables

 1. `resource_group_location`: The deployment location of resource group container for all your Azure resources
 2. `name`: An identifier used to construct the names of all resources in this template.
 3. `app_service_name`: The name key value pair where the key is representative to the app service name and value is the source container.
