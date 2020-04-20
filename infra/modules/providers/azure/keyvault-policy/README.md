# keyvault-policy

A terraform module to manage key vault permissions and policies for a specified list of resource identifiers in Azure with the following characteristics:

- Ability to create new key vault access policy(s) for a specified set of azure resources: `[object_ids]`, `tenant_id`.
- Access policy permissions are configurable: `keyvault_key_permissions`, `keyvault_secret_permissions` and `keyvault_certificate_permissions`.- Generated certificate type defaults to `application/x-pkcs12`. This is configurable through `key_vault_content_type`.
- The target keyvault reference is specified via `key_vault_id`.
- `instance_count` manages the instance count of the access policy(s). This is a temporary workaround as `count` is a static check during plan generation. This field will be removed once we're migrated to terraform 12 #118.  

## Usage

Key Vault certificate usage example:

```hcl

module "keyvault_appsvc_policy" {
  source              = "../../modules/providers/azure/keyvault-policy"
  instance_count      = "${length(keys(var.app_service_name))}"
  vault_id            = "${module.keyvault_certificate.vault_id}"
  tenant_id           = "${module.app_service.app_service_identity_tenant_id}"
  object_ids          = "${module.app_service.app_service_identity_object_ids}"
}
```

## Argument Reference

Supported arguments for this module are available in [variables.tf](./variables.tf). 