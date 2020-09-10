# Bootstrap for Terraform deployments through Gitlab into Azure

This repository is intended to simplify setting up CICD required for the infrastructure CICD on the Gitlab platform. It aims to do the following:

* Deploy Azure Dependencies required for automated CICD of Terraform deployments
* Configure variables in GitLab required for automated CICD of Terraform deployments
* Configure dependencies for each a multistage (`dev`, `integration`, `prod`, etc...) Terraform deployment

> **Note**: This template is intended to be used alongside the CICD pipeline for infrastructure using Gitlab. More information can be found [here](../../../devops/providers/gitlab/templates/README.md)
> **Note**: This template only sets up the dependencies needed to do a production ready infrastructure deployment.

There are manythings deployed by this template, including:

* Backend state storage account
* Backend state containers for this deployment
* ACR for storing docker images
* GitLab variables needed for all deployments
* For each deployment environment
  * Backend state container
  * Service principal used for deployments to that environment
  * Resource group
  * Role based security

## Identities/Credentials Configured

This template will generate some credentials, which are enumarated blow:

| Description | Reason | Notes |
| ---         | ---    | ---   |
| ACR Push/Pull | Needed by the pipeline that builds the base image used by all of the infrastructure CICD in GitLab | N/A |
| Environment Deploy | Needed by each environment to execute a deployment of resources into Azure | One generated for each environment |

## Usage

There are a few use cases for the code in this repository. The sections below outline the usage for each of those cases

### First Time Setup

Among the many resources provisioned by this template is the [Backend Configuration](https://www.terraform.io/docs/backends/index.html) that hosts the [Terraform State](https://www.terraform.io/docs/state/index.html) for this template, as well as the state for each deployment.

Because of this, we'll cannot have the backend state configured for the initial deployment of this template. These steps will take you through the following:

* Initial deployment of this template
* Enable the backend state for this deployment

#### Requirements

* `terraform` will need to be installed. Version `v0.12.28` or newer is recommended
* A shell environment, preferrably bash
* A Gitlab personall access token. Instructions for generating one can be found [here](https://docs.gitlab.com/ee/user/profile/personal_access_tokens.html). The token will need the `api` permission.
* An Azure subscription

#### Deployment Steps

**Disable backend state**

For the first deployment, the contents of `backend.tf` will need to be commented out. Don't worry -- we'll uncomment this later.

**Configure your environment**
```bash
# Required to configure variables in GitLab
export GITLAB_TOKEN="..."

# Required to scope variables to the GitLab group
export TF_VAR_group_path="..."

# Required to scope variables to the GitLab project that houses Terraform. This
# should be in the form of $GROUP/$PROJECT_NAMEexport TF_VAR_gitlab_terraform_project_path="..."

# The location in which to provision Azure resources
export TF_VAR_location="..."

# The prefix used for naming resources in Azure
export TF_VAR_prefix="..."

# Log into the Azure CLI
az login

# Set your default subscription - this will dictate where resources will be provisioned
az account set --subscription "<your subscription ID>"
```

**Run the deployment**

> **Note**: If you see a log about `Initializing the backend...`, make sure that you followed the steps to disable the backend state.

```bash
# Initialize the Terraform environment
terraform init

# See what the deployment will do. No changes will be applied, but you can review the changes that will be applied in the next step
terraform plan

# Deploy the changes
terraform apply
```

**Enable backend state**

Enabling backend state will store the deployment state in Azure. This will allow others to run the deployment without you needing to worry about the state configuration.

Start by uncommenting the contents of `backend.tf`, then run the following:

```bash
export ARM_ACCESS_KEY=$(terraform output backend-state-account-key)
export ARM_ACCOUNT_NAME=$(terraform output backend-state-account-name)
export ARM_CONTAINER_NAME=$(terraform output backend-state-bootstrap-container-name)

# Initialize the deployment with the backend
terraform init -backend-config "storage_account_name=${ARM_ACCOUNT_NAME}" -backend-config "container_name=${ARM_CONTAINER_NAME}"
```

You should see something along the lines of the following, to which you want to answer `yes`:

```bash
Do you want to copy existing state to the new backend?
```

If things work, you will see the following message and the state file should end up in Azure:

```bash
Successfully configured the backend "azurerm"! Terraform will automatically
use this backend unless the backend configuration changes.
```

### Deploying the Infrastructure

Now that Azure and GitLab have been configured to support the Terraform deployment, you will need to do the following to actually deploy the environment.

**Trigger IAC Pipeline**

You are now ready to kick off a deployment of the IAC pipeline! You can do this through the GitLab UI.

### Rotate Service Principal Passwords

If the need arrises to rotate the credentials for any of the generated service principals, the following command can be used to quickly rotate the credentials and also update all configuration in GitLab:

```bash
# configure environment (.envrc.template)

az login
az account set --subscription "<your subscription ID>"

terraform init -backend-config "storage_account_name=${ARM_ACCOUNT_NAME}" -backend-config "container_name=${ARM_CONTAINER_NAME}"

# `taint` all passwords - this triggers Terraform to regenerate these and update all dependent configuration
terraform state list | grep random_password | xargs -L 1 terraform taint
terraform plan

# Note: this command might fail due to the rapid create/delete on Azure resources. If it fails, re-running it
#       should solve the issue
terraform apply
```

Done!


### Adding a new environment

Now that Azure and GitLab have been configured to deploy the `TEK` Server through Terraform, you can easily configure Azure and GitLab to support new stages by using the `environment` module.

> **Note**: This will only set up Auzre and GitLab to support a new environment. The environment will need to be deployed using the infrastructure deployments project (not covered here).

This guide will take you through configuring Azure and GitLab to support a new `pre-prod` environment.

**Add a new environment**

You will need to open `azure.tf` to configure a new environment. A new environment can be configured by adding the following to the bottom of the file:

```hcl
module "preprod" {
  source                        = "./environment"
  acr_id                        = azurerm_container_registry.acr.id
  environment_name              = "preprod"
  location                      = var.location
  subscription_id               = data.azurerm_client_config.current.subscription_id
  backend_storage_account_name  = azurerm_storage_account.ci.name
  gitlab_terraform_project_path = var.gitlab_terraform_project_path
  prefix                        = var.prefix
}
```

You will then need to execute the following:

```bash
# configure environment (.envrc.template)

az login
az account set --subscription "<your subscription ID>"

terraform init -backend-config "storage_account_name=${ARM_ACCOUNT_NAME}" -backend-config "container_name=${ARM_CONTAINER_NAME}"
terraform plan
terraform apply
```

Done!
