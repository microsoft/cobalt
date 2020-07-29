# Module:  Azure Machine Learning Workspace

This is terraform module can be used to provision an Azure ML Workspace with the following characteristics:

- Ability to specify the existing resource group name in which the ML Workspace will be deployed.
- Ability to specify the existing resource group location, so that the ML Workspace will be deployed in the same location.
- Also gives ability to specify following settings for Azure ML Workspace based on the requirements:
  - resource_group_name : Name of the existing resource group in which the ML Workspace will be created.
  - application_insights_id : ID of the existing App Insight that is existing in the same resource group.
  - key_vault_id : ID of the existing KeyVault that is existing in the same resource group.
  - storage_account_id : ID of the storage account that is existing in the same resource group.

Please click the [link](https://www.terraform.io/docs/providers/azurerm/r/machine_learning_workspace.html) to get additional details on settings in Terraform for Azure Machine Learning Workspace.

## Usage

### Module Definition

ML Workspace Module : infra/modules/providers/azure/ml-workspace

```terraform
module "ml_workspace_walkthrough_app" {
    source                      = "../../modules/providers/azure/ml-workspace"
    name                        = "name of the workspace"
    resource_group_name         = "name of the resource group"
    application_insights_id     = "ID of the application insights"
    key_vault_id                = "ID of the KeyVault"
    storage_account_id          = "ID of the storage account"
    sku_name                    = "Basic or Enterprise"
}
```

## Outputs

Once the deployments are completed successfully, the output will be generated as it is in the [output.tf file](./output.tf).