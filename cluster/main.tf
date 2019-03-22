module "azure-provider" {
    source = "./azure/provider"
}

module "resource_group" { 
    source = "./azure/resource_group"
}


#deploy keyvault
module "keyvault" { 
    source = "./azure/keyvault"
    resource_group_location = "${module.resource_group.resource_group_location}"
    resource_group_name = "${module.resource_group.resource_group_name}"
}
