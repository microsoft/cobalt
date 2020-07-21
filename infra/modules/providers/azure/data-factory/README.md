# Data Factory

This Terrafom based data-factory module grants templates the ability to create Data factory instance along with the main components.

## _More on Data Factory_

Azure Data Factory is the cloud-based ETL and data integration service that allows you to create data-driven workflows for orchestrating data movement and transforming data at scale. Using Azure Data Factory, you can create and schedule data-driven workflows (called pipelines) that can ingest data from disparate data stores. You can build complex ETL processes that transform data visually with data flows or by using compute services such as Azure HDInsight Hadoop, Azure Databricks, and Azure SQL Database.

Additionally, you can publish your transformed data to data stores such as Azure SQL Data Warehouse for business intelligence (BI) applications to consume. Ultimately, through Azure Data Factory, raw data can be organized into meaningful data stores and data lakes for better business decisions.

For more information, Please check Microsoft Azure Data Factory [Documentation](https://docs.microsoft.com/en-us/azure/data-factory/introduction).

## Characteristics

An instance of the `data-factory` module deploys the _**Data Factory**_ in order to provide templates with the following:

- Ability to provision a single Data Factory instance
- Ability to provision a configurable Pipeline
- Ability to configure Trigger
- Ability to configure SQL server Dataset
- Ability to configure SQL server Linked Service

## Out Of Scope

The following are not support in the time being

- Creating Multiple pipelines
- Only SQL server Dataset/Linked Service are implemented.

## Definition

Terraform resources used to define the `data-factory` module include the following:

- [azurerm_data_factory](https://www.terraform.io/docs/providers/azurerm/r/data_factory.html)
- [azurerm_data_factory_integration_runtime_managed](https://www.terraform.io/docs/providers/azurerm/r/data_factory_integration_runtime_managed.html)
- [azurerm_data_factory_pipeline](https://www.terraform.io/docs/providers/azurerm/r/data_factory_pipeline.html)
- [azurerm_data_factory_trigger_schedule](https://www.terraform.io/docs/providers/azurerm/r/data_factory_trigger_schedule.html)
- [azurerm_data_factory_dataset_sql_server](https://www.terraform.io/docs/providers/azurerm/r/data_factory_dataset_sql_server_table.html)
- [azurerm_data_factory_linked_service_sql_server](https://www.terraform.io/docs/providers/azurerm/r/data_factory_linked_service_sql_server.html)

## Usage

Data Factory usage example:

```terraform
module "data_factory" {
    source              = "../../modules/providers/azure/data-factory"
    data_factory_name      = "adf"
    resource_group_name = "rg"
    data_factory_runtime_name                 = "adfrt"
    node_size                = "Standard_D2_v3"
    number_of_nodes = 1
    edition = "Standard"
    max_parallel_executions_per_node = 1
    vnet_integration = {
                    vnet_id     = "/subscriptions/resourceGroups/providers/Microsoft.Network/virtualNetworks/testvnet"
                    subnet_name = "default"
                    }
    data_factory_pipeline_name = "adfpipeline"
    data_factory_trigger_name = "adftrigger"
    data_factory_trigger_interval = 1
    data_factory_trigger_frequency = "Minute"
    data_factory_dataset_sql_name = "adfsqldataset"
    data_factory_dataset_sql_table_name = "adfsqldatasettable"
    data_factory_dataset_sql_folder = ""
    data_factory_linked_sql_name = "adfsqllinked"
    data_factory_linked_sql_connection_string = "Server=tcp:adfsql..."
}
```

## Outputs

The value will have the following schema:

```terraform

output "resource_group_name" {
  description = "The resource group name of the Service Bus namespace."
  value       = data.azurerm_resource_group.main.name
}

output "data_factory_name" {
  description = "The name of the Azure Data Factory created"
  value       = azurerm_data_factory.main.name
}

output "data_factory_id" {
  description = "The ID of the Azure Data Factory created"
  value       = azurerm_data_factory.main.id
}

output "identity_principal_id" {
  description = "The ID of the principal(client) in Azure active directory"
  value       = azurerm_data_factory.main.identity[0].principal_id
}

output "pipeline_name" {
  description = "the name of the pipeline created"
  value       = azurerm_data_factory_pipeline.main.name
}

output "trigger_interval" {
  description = "the trigger interval time for the pipeline created"
  value       = azurerm_data_factory_trigger_schedule.main.interval
}

output "sql_dataset_id" {
  description = "The ID of the SQL server dataset created"
  value       = azurerm_data_factory_dataset_sql_server_table.main.id
}

output "sql_linked_service_id" {
  description = "The ID of the SQL server Linked service created"
  value       = azurerm_data_factory_linked_service_sql_server.main.id
}

output "adf_identity_principal_id" {
  description = "The ID of the principal(client) in Azure active directory"
  value       = azurerm_data_factory.main.identity[0].principal_id
}

output "adf_identity_tenant_id" {
  description = "The Tenant ID for the Service Principal associated with the Managed Service Identity of this App Service."
  value       = azurerm_data_factory.main.identity[0].tenant_id
}
```

## Argument Reference

Supported arguments for this module are available in [variables.tf](variables.tf)