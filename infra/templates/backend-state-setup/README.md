# backend-state-setup

The `backend-state-setup` template references Bedrock's [backend-state module](https://github.com/microsoft/bedrock/tree/master/cluster/azure/backend-state) which sets up the necessary azure storage components for tracking remote Terraform deployment state. By default, Terraform will create a file named `terraform.tfstate` in the directory where Terraform is applied. Terraform needs this information so that it can be loaded when we need to know the state of the cluster for future modifications. With remote state, Terraform persists deployment state to a remote data store which can be shared between all team members.

The storage account setup should be provisioned by the subscription owners / networking admins prior to running the application specific templates.

## Provisioned Resources

This deployment creates the following:

 1. Storage Account
 2. Storage Container
 3. Resource Group

## Intended audience

Network adminitrators or technical operators that have access to a service principal with privileges to create storage accounts.

## Pattern Usage Scenario(s)

One time setup of remote backend state.

## Example Usage

1. Set the path of your template directory.
2. Call the terraform `init`, `plan`, `apply` commands to initialize the terraform deployment then write and apply the plan.

```shell
TEMPLATE_DIR=./infra/templates/backend-state-setup
STORAGE_ACCOUNT=<azure-remote-state-storage-account-prefix>
LOCATION=<storage-account-resource-group-location>
terraform init $TEMPLATE_DIR && terraform plan -var 'name=${STORAGE_ACCOUNT}' -var 'location=${LOCATION}' -out out.plan $TEMPLATE_DIR && terraform apply out.plan
```

### Template Variables

 1. `name`: Specifies the human consumable resource prefix used for the storage account and container names.
 2. `location`: Specifies the supported Azure location where the resource exists.