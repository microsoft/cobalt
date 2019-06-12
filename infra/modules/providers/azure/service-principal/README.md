# service-principal

Manages a Service Principal within Azure Active Directory.

- Optionally creates a new Service Principal and associated application in tenant of current subscription.
- Assigns newly created Service Principal or a specified Service Principal to a role provided as a variable.

## Usage

New Service Principal usage example:

```hcl

module "service-principal" {
  source                         = "../../modules/providers/azure/service-principal"
  create_for_rbac                = "true"
  service_principal_display_name = "TFTester"
  scope                          = "/subscriptions/0b1f6471-1bf0-4dda-aec3-111122223333"
  role_name                      = "reader"
}
```
Existing Service Principal usage example:

```hcl

module "service-principal" {
  source                         = "../../modules/providers/azure/service-principal"
  service_principle_object_id    = "000000-0000-000-0000-000000"
  service_principal_display_name = "TFTester"
  scope                          = "/subscriptions/0b1f6471-1bf0-4dda-aec3-111122223333"
  role_name                      = "reader"
}
```

## Attributes Reference

The following attributes are exported:

- `service_principal_object_id`: The ID of the Azure AD Service Principal
- `service_principal_application_id`: The ID of the Azure AD Application
- `service_principal_display_name`: The Display Name of the Azure AD Application associated with this Service Principal

## Argument Reference

Supported arguments for this module are available in [variables.tf](./variables.tf)