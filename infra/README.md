- [Cobalt Templates](#cobalt-templates)
- [Cobalt Modules](#cobalt-modules)
- [Directory Structure](#directory-structure)

# Cobalt Templates

Templates are the implementation of *Advocated Patterns.* The scope of a template typically covers most of if not all of the infrastructure required to host an application and may provision resources in multiple cloud provider. Templates compose modules to create an advocated pattern. They are implemented as [Terraform Modules](https://www.terraform.io/docs/configuration/modules.html) so that they can be composed if needed, though it is more commonly the case that they need not be composed.

# Cobalt Modules

Modules are the building blocks of templates. A module is a thin wrapper that enable simple common-sense configuration of related resources (typically 1-3 but sometimes more) within a cloud provider. These modules are implemented as [Terraform Modules](https://www.terraform.io/docs/configuration/modules.html).

# Directory Structure

The directory structure of Cobalt enalbes contributions for a variety of cloud providers.

```bash
$ tree -d
.
├── modules
│   └── providers
│       └── azure
│           ├── api-mgmt
│           ├── app-gateway
│           ├── app-insights
│           ├── app-monitoring
│           ├── app-service
│           ├── container-registry
│           ├── cosmosdb
│           ├── keyvault
│           ├── keyvault-cert
│           ├── keyvault-policy
│           ├── provider
│           ├── service-plan
│           ├── service-principal
│           ├── storage-account
│           └── traffic-manager
└── templates
    ├── az-hello-world
    │   └── tests
    │       ├── integration
    │       └── unit
    ├── az-isolated-service-single-region
    │   ├── docs
    │   └── tests
    │       ├── integration
    │       └── unit
    ├── az-service-single-region
    │   └── tests
    │       ├── integration
    │       └── unit
    └── backend-state-setup
```