# Azure Provider

## Summary

This module will configure a provider and install required packages mentioned below, needed by terraform to deploy Azure infrastructure resources.

## Packages

### Azure Resource Manager (Version 1.23.0 or higher)

Azure Resource Manager enables you to repeatedly deploy your app and have confidence your resources are deployed in a consistent state. In Cobalt, we use Azure Resource manager extensively for deployment of our resources using Terraform

### Terraform (Version 0.11.13 or higher)

Terraform enables you to safely and predictably create, change, and improve infrastructure. It is an open source tool that codifies APIs into declarative configuration files that can be shared amongst team members, treated as code, edited, reviewed, and versioned. In Cobalt, we use Terraform for all our resource deployments on Azure.

### Azure Active Directory

Azure Active Directory provides reliability and scalability one needs with identity services that work with on-premises, cloud, or hybrid environment. In Cobalt, Azure Active directory is used for the traffic manager role assignment.

### Null Provider 

Null Provider provided by Terraform is needed in various situations to help orchestrate tricky behavior or work around terraform limitations. In cobalt, this is used mainly in test scripts, which do not actually have a resource defined but need a null resource to execute shell scripts.
