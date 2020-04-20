# service-principal

Manages a Service Principal within Azure Active Directory.

- Optionally creates a new Service Principal and associated application in tenant of current subscription.
- Assigns newly created Service Principal or a specified Service Principal to a role provided as a variable.

## Usage

New Service Principal usage example:

```hcl

module "service-principal" {
  source                         = "../../modules/providers/azure/service-principal"
  create_for_rbac                = true
  display_name                   = "TFTester"
  role_scopes                    = ["/subscriptions/0b1f6471-1bf0-4dda-aec3-111122223333"]
  role_name                      = "reader"
}
```
Existing Service Principal usage example:

```hcl

module "service-principal" {
  source                         = "../../modules/providers/azure/service-principal"
  object_id                      = "000000-0000-000-0000-000000"
  display_name                   = "TFTester"
  role_scopes                    = ["/subscriptions/0b1f6471-1bf0-4dda-aec3-111122223333"]
  role_name                      = "reader"
}
```

## Input
Please refer to [variables.tf](./variables.tf).


## Outputs
Please refer to [output.tf](./output.tf).