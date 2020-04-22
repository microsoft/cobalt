# keyvault

A terraform module to provide key vaults in Azure with the following characteristics:

- Generates or updates a target key vault resource in azure: `keyvault_name`.
- The key vault is created in a specified resource group: `resource_group_name`.
- An access policy is created in the vault based on the deployment's service principal and tenant: environment variables `ARM_TENANT_ID` `ARM_CLIENT_SECRET` `ARM_CLIENT_ID`.
- Key Vault SKU is configurable: `keyvault_sku`. Defaults to `standard`.
- Access policy permissions for the deployment's service principal are configurable: `keyvault_key_permissions`, `keyvault_secret_permissions` and `keyvault_certificate_permissions`.
- Specified resource tags are updated to the targeted vault: `resource_tags`.

## Usage

Key Vault usage example:

```hcl

module "keyvault" {
  source              = "../../modules/providers/azure/keyvault"
  keyvault_name       = "${local.kv_name}"
  resource_group_name = "${azurerm_resource_group.svcplan.name}"
}
```

## Attributes Reference

The following attributes are exported:

- `keyvault_id`: The id of the Keyvault.
- `keyvault_uri`: The uri of the keyvault.
- `keyvault_name`: The name of the Keyvault.

## Argument Reference

Supported arguments for this module are available in [variables.tf](./variables.tf). 