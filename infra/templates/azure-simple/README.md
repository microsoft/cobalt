![image](https://user-images.githubusercontent.com/7635865/57530235-64348780-72fc-11e9-9280-9da656037c2f.png)

# The Azure Simple Pattern

The `azure-simple` template is intended to be a reference for running a single region Linux Container Azure Application Service Plan. This template exposes the app service containers to an external service endpoint through Application Gateway and Traffic Manager.

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

## Intended audience

Application developer team that want to provision a secure app service plan in a single region. 

## Prerequisites

- An Azure subscription
- A [service principal](https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal)
- An azure storage account for tracking terraform remote backend state. You can use our backend state setup [template]((/infra/templates/backend-state-setup/README.md)) to provision the storage resources.
- Install [Terraform](https://learn.hashicorp.com/terraform/getting-started/install.html)
- Local environment [setup](https://github.com/microsoft/cobalt/blob/erisch/features/bashwizard/test-harness/README.md#local-environment-setup)

## Example Usage

1. Create a new terraform template directory and add a `main.tf` file. Here's a sample that uses the `azure-simple` template.

```HCL
module "azure-simple" {
  name                            = "cobalt-azure-simple"
  resource_group_location         = "eastus"
  source                          = "https://github.com/microsoft/cobalt/tree/master/infra/templates/azure-simple"
  app_service_name                = {cobalt-backend-api = "DOCKER|msftcse/cobalt-azure-simple:0.1"}
}
```

2. Call the terraform `init`, `plan`, `apply` commands within the template directory to initialize the terraform deployment then write and apply the plan.

```bash
export TF_VAR_remote_state_account=<tf-remote-state-storage-account-name>
export TF_VAR_remote_state_container=<tf-remote-state-storage-container-name>
terraform init -backend-config "storage_account_name=${TF_VAR_remote_state_account}" -backend-config "container_name=${TF_VAR_remote_state_container}"
terraform plan
terraform apply
```

### Template Variables

#### Required Variables

 1. `resource_group_location`: The deployment location of resource group container all the resources.
 2. `name`: The name of the deployment.  This will be used across the resource created in this solution.
 3. `app_service_name`: The name key value pair where the key is representative to the app service name and value is the source container.

#### Optional Variables

 Checkout the `variables.tf` for all optional `azure-simple` configuration settings.