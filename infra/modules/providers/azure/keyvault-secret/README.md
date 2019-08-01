# keyvault-secret

A terraform module to provide Key Vaults secrets for existing Key Vaults in Azure with the following characteristics:

- Secrets have a name that identifies them in the URL/ID
- Secrets have a secret value that gets encrypted and protected by the key vault

## Usage

Key Vault secret usage example:

```hcl
secrets = [
  {
    name  = "secret_sauce"
    value = "chunky marinara"
  }
]

kv_id = "234222"

module "keyvault-secret" {
  source               = "../../modules/providers/azure/keyvault-secret"
  keyvault_id          = kv_id
  secrets              = secrets
}
```

## Variables Reference

The following variables are used:

- `secrets`: A list of Key Vault Secrets.
- `keyvault_id`: The id of the Key Vault.

## Attributes Reference

The following attributes are exported:

- `keyvault_secret_ids`: The id of the Key Vault secret.
- `keyvault_secret_versions`: The version of the Key Vault secret.
