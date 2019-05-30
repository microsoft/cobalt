# traffic-manager

A terraform module to manage a traffic manager instance and it's endpoints in Azure with the following characteristics:

- Ability to create or update a traffic manager profile. Traffic routing method is set to `Weighted`.
- The profile is created in the specified resource group `resource_group_name`.
- The DNS name on the profile is configured: `traffic_manager_dns_name`.
- The monitoring protocol and port are specified through `traffic_manager_monitor_protocol` and `traffic_manager_monitor_port`. Defaults to https and 443.
- Specified resource tags are updated to the targeted vault: `resource_tags`.
- One traffic manager endpoint is created along with a dynamic Public IP address. The endpoint is bounded to the traffic manager profile. The weighting of the endpoint is set to `1`.
- The DNS name is configured via `public_ip_name`.

## Usage

Key Vault certificate usage example:

```hcl

module "traffic_manager" {
  source                       = "../../modules/providers/azure/traffic-manager"
  resource_group_name          = "${azurerm_resource_group.svcplan.name}"
  traffic_manager_profile_name = "${local.tm_profile_name}"
  public_ip_name               = "${local.public_pip_name}"
  endpoint_name                = "${local.tm_endpoint_name}"
  traffic_manager_profile_name = "${local.tm_profile_name}"
  traffic_manager_dns_name     = "${local.tm_dns_name}"
}
```

## Attributes Reference

The following attributes are exported:

- `public_pip_id`: The resource id for the public dns.
- `tm_fqdn`: The fully qualified domain name for the traffic manager profile.
- `public_pip_fqdn`: The fully qualified domain name for the public dns.

## Argument Reference

Supported arguments for this module are available in [variables.tf](./variables.tf).