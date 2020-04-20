# Azure Provider

## Summary

This module will configure a provider and install required packages mentioned below, needed by terraform to deploy Azure infrastructure resources.

## Packages

### Azure Resource Manager (Version 1.23.0 or higher)

Azure Resource Manager enables you to repeatedly deploy your app and have confidence your resources are deployed in a consistent state. In Cobalt, we use Azure Resource manager extensively for deployment of our resources using Terraform

#### Usage

Below code snippet example will use Azure Resource Manager to deploy a resource of type resource group. Additional details regarding Azure Resource Manager on Terraform can be found [here](https://www.terraform.io/docs/providers/azurerm/index.html)

```
resource "azurerm_resource_group" "example" {
  name     = "${var.resource_group_name}"
  location = "${var.resource_group_location}"
}
```

### Terraform (Version 0.12.2 or higher)

Terraform enables you to safely and predictably create, change, and improve infrastructure. It is an open source tool that codifies APIs into declarative configuration files that can be shared amongst team members, treated as code, edited, reviewed, and versioned. In Cobalt, we use Terraform for all our resource deployments on Azure.

#### Usage

Below are the commands used for deploying resources on Azure using terraform templates. List of all terraform commands can be found [here](https://www.terraform.io/docs/commands/index.html)

```
terraform init  <folder-name>
terraform apply <folder-name>
```

### Azure Active Directory

Azure Active Directory provides reliability and scalability one needs with identity services that work with on-premises, cloud, or hybrid environment. In Cobalt, Azure Active directory is used for the traffic manager role assignment.

#### Usage

Below code snippet example uses Azure Active Directory to Read service principal object to create a role assignment. Additional details regarding Azure Active Directory on Terraform can be found [here](https://www.terraform.io/docs/providers/azuread/index.html)

```
data "azuread_service_principal" "example" {
    application_id = "${var.service_principal_id}"
}
```

### Null Provider 

Null Provider provided by Terraform is needed in situations where one wants to execute external scripts to get configuration details of resources, not provided by terraform outputs, that are going to be created using terraform. In Cobalt, this is used mainly in test scripts, which do not actually have a resource defined but need a null resource to execute shell scripts.

#### Usage

Below code snippet example uses Null Provider to update trigger based on the trigger condition and executes the shell script locally. Additional details regarding Null Provider on Terraform can be found [here](https://www.terraform.io/docs/providers/null/index.html)

```
resource "null_resource" "example" {
    triggers {
        trigger = trigger-condition
    }
    provisioner "local-exec" {
        command = "execute shell script"
    }
}
```