![image](https://user-images.githubusercontent.com/7635865/57530235-64348780-72fc-11e9-9280-9da656037c2f.png)

# The Azure Simple Pattern

The `az-service-single-region` template is intended to be a reference for running a single region Linux Container Azure Application Service Plan. This template exposes the app service containers to an external service endpoint through Application Gateway and Traffic Manager.

## Use-Case

This particular envrironment allows developers to easily try out Cobalt on Azure.

## Provisioned Resources

This deployment creates the following:

 1. Linux App Service Plan
 2. App Service Container + staging slot
 3. Application Insights Instance
 4. vnet + subnet for app gateway
 5. Application Gateway with an enabled Firewall
 6. Traffic Manager Profile
 7. Traffic Manager Endpoint
 8. Azure Monitoring Rules
 9. Public IP(for TM + AG)
 10. Azure Container Registry
 11. ACR Webhook

## Intended audience

Application developer team that want to provision a secure app service plan in a single region. 

## Prerequisites

- An Azure subscription
- A [service principal](https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal)
- An Azure storage account for tracking terraform remote backend state. You can use our backend state setup [template](/infra/templates/backend-state-setup/README.md) to provision the storage resources.
- Install [Terraform](https://learn.hashicorp.com/terraform/getting-started/install.html)
- Local environment [setup](https://github.com/microsoft/cobalt/tree/master/test-harness#local-environment-setup)

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

3. Create a new terraform template directory and add a `main.tf` file. Here's a sample that uses the `az-service-single-region` template.

```HCL
module "az-service-single-region" {
  name                            = "az-service-single-region"
  resource_group_location         = "eastus"
  source                          = "github.com/microsoft/cobalt/infra/templates/az-service-single-region"
  app_service_name                = {cobalt-backend-api = "DOCKER|msftcse/az-service-single-region:0.1"}
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

### Template Variables

#### Required Variables

 1. `resource_group_location`: The deployment location of resource group container all the resource
 2. `name`: An identifier used to construct the names of all resources in this template.
 3. `app_service_name`: The name key value pair where the key is representative to the app service name and value is the source container.

#### Optional Variables

 Check out the `variables.tf` for all optional `az-service-single-region` configuration settings.