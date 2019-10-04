![pending architecture]()

# The Azure Hello World Pattern

The `az-hello-world` template is intended to be a reference for running a single public Linux Container within an Azure Application Service Plan.

>> *Have you completed the quick start guide? Deploy your first infrastructure as code project with Cobalt by following the [quick-start guide](./2_QUICK_START_GUIDE.md).*

## Use-Case

This particular template creates an Azure environment with our smallest infrastructure footprint and is the recommended template highlighted in our [quick-start guide](../../../docs/2_QUICK_START_GUIDE.md).

## Provisioned Resources

This deployment creates the following:

 1. Azure Resource Group
 2. Linux App Service Plan
 3. App Service Container w/ public i.p.

## Intended audience

Application developer that is brand new to Cobalt templating and the *Cobalt Infrastructure Template* (CIT) developer workflow.

## Prerequisites

  * App dev experience (Previous "Infrastructure as Code" experience not required)
  * An Azure Subscription
  * A [service principal](https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal)
  * An Azure Storage Account for tracking terraform remote backend state. You can use our backend state setup [template](../infra/templates/backend-state-setup/README.md) to provision the storage resources.
  * WSL or Bash
  * Local environment [setup](https://github.com/microsoft/cobalt/tree/master/test-harness#local-environment-setup)
  * Install [git](https://www.atlassian.com/git/tutorials/install-git)
  * Install [Terraform](https://learn.hashicorp.com/terraform/getting-started/install.html)
  * Azure CLI
    * [Get started with Azure CLI](https://docs.microsoft.com/en-us/cli/azure/get-started-with-azure-cli?view=azure-cli-latest)

## Example Usage

1. Execute the following commands to set up your local environment variables:

```bash
# these commands setup all the environment variables needed to run this template
DOT_ENV=<path to your .env file>
export $(cat $DOT_ENV | xargs)
```

2. Execute the following command to configure your local Azure CLI. **Note**: This is a temporary measure until we are able to break the dependency on the Azure CLI. This work is being tracked as a part of [Issue 153](https://github.com/microsoft/cobalt/issues/153)

```bash
# This logs your local Azure CLI in using the configured service principal.
az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID
```

3. Navigate to the main.tf terraform file of the [az-hello-world](./main.tf) template directory. Here's a sample of the main.tf that the `az-hello-world` template uses.

```HCL
module "app_service" {
  source                           = "../../modules/providers/azure/app-service"
  app_service_name_prefix          = local.app_svc_name_prefix #""
  service_plan_name                = module.service_plan.service_plan_name #""
  service_plan_resource_group_name = azurerm_resource_group.main.name #""
  docker_registry_server_url       = local.reg_url #""
  app_service_config               = local.app_services #"{cobalt-backend-api = "DOCKER|appsvcsample/static-site:latest"}"
}
```

4. Execute the following commands to set up your terraform environment.

```bash
# This configures terraform to leverage a remote backend that will help you and your
# team keep consistent state
terraform init -backend-config "storage_account_name=${TF_VAR_remote_state_account}" -backend-config "container_name=${TF_VAR_remote_state_container}"

# This command configures terraform to use a workspace unique to you. This allows you to work
# without stepping over your teammate's deployments
terraform workspace new $USER || terraform workspace select $USER
```

5. Execute the following commands to orchestrate a deployment.

```bash
# See what terraform will try to deploy without actually deploying
terraform plan

# Execute a deployment
terraform apply
```

6. Optionally execute the following command to teardown your deployment and delete your resources.

```bash
# Destroy resources and tear down deployment. Only do this if you want to destroy your deployment.
terraform destroy
```

#### Required Variables

 1. `resource_group_location`: The deployment location of resource group container for all your Azure resources
 2. `name`: An identifier used to construct the names of all resources in this template.
 3. `app_service_name`: The name key value pair where the key is representative to the app service name and value is the source container.

#### Optional Variables

 Check out the `variables.tf` for all optional `az-hello-world` configuration settings.