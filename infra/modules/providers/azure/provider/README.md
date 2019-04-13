# Azure Provider

## Summary

This module will configure a provider needed by terraform to deploy Azure infrastructure resources.

The below packages would be installed with this module:
- Azure Resource Manager Module
- Terraform
- Azure Active Directory (Needed for the traffic manager role assignment)
- Null Provider (Needed in various situations to help orchestrate tricky behavior or work around terraform limitations)
