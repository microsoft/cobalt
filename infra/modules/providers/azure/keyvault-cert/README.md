# keyvault-cert

A terraform module to provide certificate to a target key vault instance in Azure with the following characteristics:

- Ability to import an existing certificate file into a specified key vault instance. This feature is enabled through the `key_vault_cert_import_filepath` configuration.
- Generate a self signed certificate when provided the key subject alternative names and a CN subject: `key_vault_cert_alt_names`, `key_vault_cert_subject`. The generated certificate is imported to the target key vault: `keyvault_name`. Self signed certificates should only be used for development purposes.
- Generated certificate type defaults to `application/x-pkcs12`. This is configurable through `key_vault_content_type`.
- The certificate expiration policy is configurable through `key_vault_cert_validity_months` and `key_vault_cert_days_before_expiry`. Defaults to `12` and `30`.
- Private and public certificate contents are exposed as sensitive output secrets: `private_pfx` and `public_cert`. This is required for binding the imported certificate to azure managed services like App Gateway for SSL termination.

## Usage

Key Vault certificate usage example:

```hcl

module "keyvault_certificate" {
  source                   = "../../modules/providers/azure/keyvault-cert"
  keyvault_name            = "${module.keyvault.keyvault_name}"
  resource_group_name      = "${azurerm_resource_group.svcplan.name}"
  key_vault_cert_subject   = "${module.traffic_manager.public_pip_fqdn}"
  key_vault_cert_alt_names = ["${module.app_service.app_service_uri}"]
}
```

## Attributes Reference

The following attributes are exported:

- `cert_name`: The name of the generated certificate in key vault.
- `public_cert`: The contents of the generated public `cer` certificate. The output value is marked as `sensitive`.
- `private_pfx`: The contents of the generated private `pfx` key. The output value is marked as `sensitive`.

## Argument Reference

Supported arguments for this module are available in [variables.tf](./variables.tf).

## License
Copyright © Microsoft Corporation

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at 

[http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.