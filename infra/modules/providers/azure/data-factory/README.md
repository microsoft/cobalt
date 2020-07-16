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


## Out Of Scope

The following are not support in the time being

- Creating Multiple pipelines

## Definition

Terraform resources used to define the `data-factory` module include the following:

- [azurerm_data_factory](https://www.terraform.io/docs/providers/azurerm/r/data_factory.html)
- [azurerm_data_factory_integration_runtime_managed](https://www.terraform.io/docs/providers/azurerm/r/data_factory_integration_runtime_managed.html)
- [azurerm_data_factory_pipeline](https://www.terraform.io/docs/providers/azurerm/r/data_factory_pipeline.html)
- [azurerm_data_factory_trigger_schedule](https://www.terraform.io/docs/providers/azurerm/r/data_factory_trigger_schedule.html)

## Usage

Data Factory usage example:

``` yaml
module "data_factory" {
  source                           = "../../modules/providers/azure/data-factory"
  data_factory_name                = "adf"
  resource_group_name              = "rg"
  data_factory_runtime_name        = "adfrt"
  node_size                        = "Standard_D2_v3"
  number_of_nodes                  = 1
  edition                          = "Standard"
  max_parallel_executions_per_node = 1
  vnet_integration = {
    vnet_id     = "/subscriptions/resourceGroups/providers/Microsoft.Network/virtualNetworks/testvnet"
    subnet_name = "default"
  }
  data_factory_pipeline_name                = "adfpipeline"
  data_factory_trigger_name                 = "adftrigger"
  data_factory_trigger_interval             = 1
  data_factory_trigger_frequency            = "Minute"
}
```

## Outputs

The output values for this module are available in [output.tf](output.tf)


## Argument Reference

Supported arguments for this module are available in [variables.tf](variables.tf)