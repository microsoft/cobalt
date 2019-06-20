# Azure Storage

This Terraform based `storage-account` module grants templates the ability to configure and deploy cloud `storage containers` along with a `storage account` using Microsoft's _**Azure Storage**_ service.

In addition, this module offers both authentication and authorization features:

- For authentication, this module automatically enrolls the deployed `storage account` into Microsoft's _**Managed Identities**_ service.

- For authorization, this module expects to receive the `object id` of any Azure Resource that will behave as a client of the `storage-account`. Enrollment as an Azure Resource client is achieved through Microsoft's _**Role Based Access Secruity**_ (RBAC) service.

#### _More on Azure Storage_

> "A storage account provides a unique namespace in Azure for your data. Every object that you store in Azure Storage has an address that includes your unique account name. A container organizes a set of blobs, similar to a directory in a file system. A storage account can include an unlimited number of containers, and a container can store an unlimited number of blobs." - Source: Microsoft's [Introduction to Azure Blob Storage](https://docs.microsoft.com/en-us/azure/storage/blobs/storage-blobs-introduction)

This module deploys a `storage account` along with a `storage container` in order to satisfy blob storage scenarios which are optimized for storing massive amounts of unstructured data, such as text or binary data.

## Characteristics

An instance of the `storage-account` module deploys the _**Azure Storage**_ service in order to provide templates with the following:

- Ability to deploy a Storage Account automatically enrolled into _**Managed Identities**_ within a single resource group.

- Ability to deploy a Storage Account with a role assigned Azure Resource client.

- Ability to deploy a Storage Container within the Storage Account.

## Definition

Terraform resources directly referenced within the `storage-account` module include the following:

- [azurerm_storage_account](https://www.terraform.io/docs/providers/azurerm/r/storage_account.html)

- [azurerm_storage_container](https://www.terraform.io/docs/providers/azurerm/r/storage_container.html)

## Usage

Azure Storage usage example:

```terraform
resource "azurerm_resource_group" "main" {
  name     = var.prefix
  location = var.resource_group_location
}

module "service_plan" {
  source              = "../../modules/providers/azure/service-plan"
  resource_group_name = azurerm_resource_group.main.name
  service_plan_name   = "${azurerm_resource_group.main.name}-sp"
}

module "app_service" {
  source                           = "../../modules/providers/azure/app-service"
  app_service_name                 = var.app_service_name
  service_plan_name                = module.service_plan.service_plan_name
  ...
}

module "storage_account" {
  source                            = "../../modules/providers/azure/storage-account"
  resource_group_name               = azurerm_resource_group.main.name
  resource_group_location           = azurerm_resource_group.main.location
  account_name                      = "teststorageaccount"
  storage_container_names           = ["teststorageaccount", "teststorageaccount"]
  encryption_source                 = "Microsoft.Storage"
  existing_sp_object_id             = module.app_service.app_service_identity_object_ids[0]
}
```

#### Configuring `storage account`

Please visit _**Azure Storage's**_ [Introduction to Azure Storage](https://docs.microsoft.com/en-us/azure/storage/common/storage-introduction.) page for more information on configuring a storage account.

#### Configuring `rbac role`

Please visit _**Cobalt's**_ [service principal module](../service-principal) page for more information on configuring a service principal and rbac role.

## Argument Reference

Supported arguments for this module are available in [variables.tf](variables.tf).

## Attributes Reference

The following attributes are exported:

- `storage_account_id`: The ID of the storage account.
- `storage_account_managed_identities_id`: The principal ID generated from enabling a Managed Identity with this storage account.
- `storage_account_tenant_id`: The tenant ID for the Service Principal of this storage account.
- `storage_container_id`: The ID of the storage container from the storage account module.
- `storage_container_properties`: Map of additional properties associated with the storage container.

  ```terraform
      azurerm_storage_container.sa.properties[last_modified]
      azurerm_storage_container.sa.properties[lease_duration]
      azurerm_storage_container.sa.properties[lease_state]
      azurerm_storage_container.sa.properties[lease_status]
  ```
