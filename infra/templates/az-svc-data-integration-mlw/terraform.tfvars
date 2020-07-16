# Note: These values will impact the names of resources. If your deployment
# fails due to a resource name collision, consider using different values for
# the `name` variable or increasing the value for `randomization_level`.

resource_group_location = "southcentralus"
prefix                  = "smpl"
randomization_level     = 8


app_services = [{
  app_name         = "smpl"
  app_command_line = null
  image            = null
  linux_fx_version = ""
  app_settings = {
    service_domain_name = "contoso.com"
  }
}]

# Note: this is configured as such only to test IP Whitelists. This is a well
# known DNS address


sys_storage_containers = []

app_storage_containers = [
  "sample",
  "acidatadriftdata",
  "configuration",
  "source",
]

subnet_service_endpoints = [
  "Microsoft.Web",
  "Microsoft.ContainerRegistry",
  "Microsoft.Storage",
  "Microsoft.KeyVault",
  "Microsoft.AzureActiveDirectory",
  "Microsoft.AzureCosmosDB",
]

func_subnet_service_endpoints = [
  "Microsoft.Web",
  "Microsoft.ContainerRegistry",
  "Microsoft.Storage",
  "Microsoft.KeyVault",
  "Microsoft.AzureActiveDirectory"
]

fn_app_config = {
  "mlops-orchestrator" = {
    image = "",
    zip   = "",
    hash  = "",
  }
}

primary_replica_location = "eastus2"