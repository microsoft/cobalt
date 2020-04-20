# Azure Storage

This Terraform based `storage-account` module grants templates the ability to configure and deploy cloud `storage containers` along with a `storage account` using Microsoft's _**Azure Storage**_ service.

In addition, this module offers both authentication and authorization features:

- For authentication, this module automatically enrolls the deployed `storage account` into Microsoft's _**Managed Identities**_ service.


#### What is Azure Storage?

From the official [Documentation](https://docs.microsoft.com/en-us/azure/storage/common/storage-introduction):

> "A storage account provides a unique namespace in Azure for your data. Every object that you store in Azure Storage has an address that includes your unique account name. A container organizes a set of blobs, similar to a directory in a file system. A storage account can include an unlimited number of containers, and a container can store an unlimited number of blobs." - Source: Microsoft's [Introduction to Azure Blob Storage](https://docs.microsoft.com/en-us/azure/storage/blobs/storage-blobs-introduction)

This module deploys a `storage account` along with `storage containers` in order to satisfy blob storage scenarios which are optimized for storing massive amounts of unstructured data, such as text or binary data.

## Current Features

An instance of the `storage-account` module deploys the _**Azure Storage**_ service in order to provide templates with the following:

- Ability to deploy Storage Containers alongside deploying a Storage Account.


## Module Usage

Azure Storage usage example:

```terraform
resource "azurerm_resource_group" "sample" {
  name     = var.prefix
  location = var.resource_group_location
}

module "storage_account" {
  source              = "../../modules/providers/azure/storage-account"

  name                = "mystorageaccount"
  container_names     = ["test"]
  resource_group_name = azurerm_resource_group.sample.name
}
```

### Resources

| Resource | Terraform Link | Description |
|---|---|---|
| `azurerm_storage_account` | [storage account](https://www.terraform.io/docs/providers/azurerm/r/storage_account.html) | This resource will be declared within the module. |
| `azurerm_storage_container` | [storage container](https://www.terraform.io/docs/providers/azurerm/r/storage_container.html) | This resource will be declared within the module. |


### Input Variables

Please refer to [variables.tf](./variables.tf).

### Output Variables

Please refer to [output.tf](./output.tf).

### Automated Tests


_Setup the Environment._
```bash
# Copy the environment template and populate required values for RESOURCE_GROUP_NAME STORAGE_ACCOUNT_NAME and CONTAINER_NAME in .env
cp ./tests/.env.testing.template .env

# Export the environment variables.
export $(cat .env | xargs)

# Create a resource group if one does not exist.  (OPTIONAL)
az group create --name $RESOURCE_GROUP_NAME --location eastus2

## Create a tfvars file from the environment values.
cat > testing.tfvars << EOF
name = "$STORAGE_ACCOUNT_NAME"

container_names = [
  "$CONTAINER_NAME"
]

resource_group_name = "$RESOURCE_GROUP_NAME"
EOF
```

>This module's tests validate a provisioned Terraform workspace.

```bash
terraform init
terraform plan --var-file=testing.tfvars
terraform apply --var-file=testing.tfvars
```

__Execute Unit Tests__

`go test -v $(go list ./... | grep "unit")`

__Execute Integration Tests__

`go test -v $(go list ./... | grep "integration")`

