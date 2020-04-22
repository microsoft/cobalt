## api-mgmt

The API Management cobalt module allows terraform templates to configure and provision an Azure API Management service and the critical resources found in most instances. API Management provides the core competencies to ensure a successful API program through developer engagement, business insights, analytics, security, and protection. Azure API Management can be used to take any backend and launch a full-fledged API program based on it. Package and publish APIs to external, partner, and internal developers securely and at scale using the fully managed platform to manage and deploy the required infrastructure.

More information on Azure API Management can be found [here](https://azure.microsoft.com/en-us/services/api-management/).

## Characteristics

Cobalt provides the ability to provision an API Management service along with the following characteristics:

- Provisions a single API Management service into the specified resource group with control over sku, publisher info, policies, and tags
- Supports creation of apis through specification files with full versioning capabilities
- Supports creation of groups
- Supports creation of products and allows for association with apis and groups
- Supports creation of backends
- Supports creation of named values
- Supports policies for services, apis, products, and operations
- Supports tags for services, apis, products, and named values

## Usage

Example that includes all possible service, api, version set, product, group, backend, named value, policy, and tag values:

```hcl
resource "azurerm_resource_group" "rg" {
  name     = "cobalt-rg"
  location = "East US"
}

locals {
  basic_policy      = <<XML
<policies>
    <inbound />
    <backend />
    <outbound />
    <on-error />
</policies>
XML
  rate_limit_policy = <<XML
<policies>
    <inbound>
    <rate-limit-by-key calls="10" renewal-period="120" counter-key="@(context.Request.IpAddress)"/>
        <base />
    </inbound>
    <backend />
    <outbound />
    <on-error />
</policies>
XML
}

module "api_management" {
  source              = "../cobalt/infra/modules/providers/azure/api-mgmt"
  resource_group_name = azurerm_resource_group.rg.name
  apim_service_name   = "cobalt-apim-service"
  sku_tier            = "Developer"
  sku_capacity        = 1
  publisher_name      = "Microsoft"
  publisher_email     = "test@microsoft.com"
  tags = {
    Environment = "dev"
  }
  available_tags = [
    {
      name         = "testtag"
      display_name = "testtag"
    }
  ]
  policy = {
    content = local.basic_policy
    format  = "xml"
  }
  groups = [
    {
      name         = "testgroup"
      display_name = "testgroup"
      description  = "a test group"
      external_id  = null
      type         = null
    }
  ]
  api_version_sets = [
    {
      name                = "testversionset"
      display_name        = "testversionset"
      versioning_scheme   = "Segment"
      description         = "a test version set"
      version_header_name = null
      version_query_name  = null
    }
  ]
  apis = [
    {
      name         = "petstore"
      display_name = "petstore"
      description  = "a test api"
      revision     = "1"
      path         = "petstore"
      protocols    = ["http"]
      api_import_file = {
        content = "https://petstore.swagger.io/v2/swagger.json"
        format  = "swagger-link-json"
      }
      version                       = "v1"
      existing_version_set_id       = null
      provisioned_version_set_index = 0
      tags                          = ["testtag"]
      policy = {
        content = local.rate_limit_policy
        format  = "xml"
      }
      operation_policies = [
        {
          operation_id = "getPetById"
          content      = local.rate_limit_policy
          format       = "xml"
        }
      ]
    }
  ]
  products = [
    {
      product_id            = "testproduct"
      display_name          = "testproduct"
      description           = "a test product"
      subscription_required = true
      approval_required     = false
      published             = true
      apis                  = ["petstore"]
      groups                = ["testgroup"]
      tags                  = ["testtag"]
      policy = {
        content = local.rate_limit_policy
        format  = "xml"
      }
    }
  ]
  named_values = [
    {
      name         = "testnamedvalue"
      display_name = "test_named_value"
      value        = "a test value"
      secret       = false
      tags         = ["testtag"]
    }
  ]
  backends = [
    {
      name        = "testbackend"
      protocol    = "http"
      url         = "https://petstore.swagger.io/v2"
      description = "a test backend"
    }
  ]
}
```

## Outputs

Once the deployments are completed successfully, the output for the module will be in the format mentioned below:

```hcl
Outputs:

api_outputs = {
  "petstore" = {
    "id" = "/subscriptions/54ba26c5-cf88-4954-8400-013f761041fd/resourceGroups/cobalt-rg/providers/Microsoft.ApiManagement/service/cobalt-apim-service/apis/petstore"
    "is_current" = true
    "is_online" = false
    "version" = "v1"
    "version_set_id" = "/subscriptions/54ba26c5-cf88-4954-8400-013f761041fd/resourceGroups/cobalt-rg/providers/Microsoft.ApiManagement/service/cobalt-apim-service/api-version-sets/testversionset"
  }
}
api_version_set_ids = {
  "testversionset" = "/subscriptions/54ba26c5-cf88-4954-8400-013f761041fd/resourceGroups/cobalt-rg/providers/Microsoft.ApiManagement/service/cobalt-apim-service/api-version-sets/testversionset"
}
backend_ids = {
  "testbackend" = "/subscriptions/54ba26c5-cf88-4954-8400-013f761041fd/resourceGroups/cobalt-rg/providers/Microsoft.ApiManagement/service/cobalt-apim-service/backends/testbackend"
}
gateway_url = https://cobalt-apim-service.azure-api.net
group_ids = {
  "testgroup" = "/subscriptions/54ba26c5-cf88-4954-8400-013f761041fd/resourceGroups/cobalt-rg/providers/Microsoft.ApiManagement/service/cobalt-apim-service/groups/testgroup"
}
named_value_ids = {
  "testnamedvalue" = "/subscriptions/54ba26c5-cf88-4954-8400-013f761041fd/resourceGroups/cobalt-rg/providers/Microsoft.ApiManagement/service/cobalt-apim-service/properties/testnamedvalue"
}
product_api_ids = [
  "/subscriptions/54ba26c5-cf88-4954-8400-013f761041fd/resourceGroups/cobalt-rg/providers/Microsoft.ApiManagement/service/cobalt-apim-service/products/testproduct/apis/petstore",
]
product_group_ids = [
  "/subscriptions/54ba26c5-cf88-4954-8400-013f761041fd/resourceGroups/cobalt-rg/providers/Microsoft.ApiManagement/service/cobalt-apim-service/products/testproduct/groups/testgroup",
]
product_ids = {
  "testproduct" = "/subscriptions/54ba26c5-cf88-4954-8400-013f761041fd/resourceGroups/cobalt-rg/providers/Microsoft.ApiManagement/service/cobalt-apim-service/products/testproduct"
}
service_id = /subscriptions/54ba26c5-cf88-4954-8400-013f761041fd/resourceGroups/cobalt-rg/providers/Microsoft.ApiManagement/service/cobalt-apim-service
service_identity_object_id = 13973d26-4aff-4b60-9c98-56cfa814dc8d
service_identity_tenant_id = 72f988bf-86f1-41af-91ab-2d7cd011db47
service_public_ip_addresses = [
  "13.72.70.234",
]
```

## Attributes Reference

The following attributes are exported:

- `service_id`: The ID of the API Management Service created
- `gateway_url`: The URL of the Gateway for the API Management Service
- `service_public_ip_addresses`: The Public IP addresses of the API Management Service
- `service_identity_tenant_id`: The Tenant ID for the Service Principal associated with the Managed Service Identity of this API Management Service
- `service_identity_object_id`: The Principal ID for the Service Principal associated with the Managed Service Identity for the API Management Service
- `api_outputs`: The IDs, state, and version outputs of the APIs created
- `group_ids`: The IDs of the API Management Groups created
- `api_version_set_ids`: The IDs of the API Version Sets created
- `product_ids`: The IDs of the Products created
- `named_value_ids`: The IDs of the Named Values created
- `backend_ids`: The IDs of the Backends created
- `product_api_ids`: The IDs of the Product/API associations created
- `product_group_ids`: The IDs of the Product/Group associations created

## Argument Reference

Supported arguments for this module are available in [variables.tf](./variables.tf) with information on which inputs are required vs optional.
