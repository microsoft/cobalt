# Version and Go Technical Design Purpose

This design addresses Cobalt's workflow to deploy individual application infrastructure using a Cobalt template.

## Definitions
 - `Operations Team (Ops Team)` - DevOps or Operations team consisting of Infrastructure Administrators or similar roles.
 - `Application Team (App Team)` - Software Developers with an application to deploy to Azure.
 - `Development Repo (Dev Repo)` - Cobalt's repo hosted on Github at [https://github.com/microsoft/cobal](https://github.com/microsoft/cobal)
 - `Operations Repo (Ops Repo)` - Individual template repository managed by the `Operations Team`
 - `Application Repo (App Repo)` - Repository that contains the application code to be deployed and managed by the `Application Team`
 - `Version` - all versioning schemes should use [SemVer](https://semver.org/) or variant. [ref: Terraform Versioning](https://www.terraform.io/docs/extend/best-practices/versioning.html)

## Version and Go Setup Description
Our design starts after the initial Cobalt setup, where an individual template is cloned into an organizations source control (ref: [Setup Doc](https://github.com/microsoft/cobalt/blob/master/docs/GETTING_STARTED_APP_DEV.md)). An application development team is ready to start deploying their code to infrastructure built in Azure. Typically they would make a request to the Operations Team. The Ops Team would provide the App team with a link to the latest infra configuration files for a specific template. The App team downloads this tar/zip file and extracts the folder/files.

```
infra/
 |_ Application.tf
 |_ Application.yaml
```

These files could be derived from the template folder in dev repo and cloned into the Ops Repo. Proposed folder path/location is:

```
infra/
  |_template
      |_template_name
          |_tests
          |_config
          |   |_ application.tf
          |_template files...
```

```
devops/
  |_ providers
      |_ azure-devops
          |_ templates
              |_ infrastructure
                  |_ application.yaml
```

We could also approach this using documentation. The idea would be it's the organizations responsibility to create or provide guidance on creating. This would simplify the overall design.

 - `Appliation.tf` is the artifact that points to the template in the Ops Repo. The application team would need to fill this file out with the requested configuration. Example:

 ```hdl
 module "az-isolated-service-single-region" {
   source = "git://dev.azure.com/project/repo?ver=1.0.0//infra/template/az-isolated-service-single-region/"
   resource_group_location = "eastus"
   name = "az-simple"
   deployment_targets = [{
     app_name = "cobalt-backend-api",
     image_name = "msftcse/az-service-single-region",
     image_release_tag_prefix = "release"
   }]
   acr_build_git_source_url = "https://github.com/erikschlegel/echo-server.git"
}
 ```

> Note this could be replaced by documentation and ref: [https://www.terraform.io/docs/modules/sources.html](https://www.terraform.io/docs/modules/sources.html)

 - `Application.yaml` - is the artifact that points to the azure-pipeline.yml file in the Ops Repo that contains the build/test/deploy pipeline.

```yaml
# Repo: Contoso/WindowsProduct
# File: azure-pipelines.yml
resources:
  repositories:
    - repository: templates
      type: github
      name: Contoso/BuildTemplates
      ref: refs/tags/v1.0 # optional ref to pin to

jobs:
- template: common.yml@templates  # Template reference
  parameters:
    vmImage: 'vs2017-win2016'
```

> Azure pipelines supports referencing pipeline files in other repos/branches: [https://docs.microsoft.com/en-us/azure/devops/pipelines/process/templates?view=azure-devops#using-other-repositories](https://docs.microsoft.com/en-us/azure/devops/pipelines/process/templates?view=azure-devops#using-other-repositories)

This folder/files should be checked into the root of the app repo. The Ops Team would then configure a new pipeline in the app teams Azure Devops project to point to these files and deploy the requested infrastructure.

> Note: We should strive to continue to use a single set of pipeline files for all pipelines referenced in this document.

## Version and Go Ops Pipeline Description

Should the Operations Repo CI/CD pipeline output the zip file containing the Application.tf/yaml files as an artifact that is shareable? The name should contain the SemVer denoted. This should also be a link that is accessible not only by the Operations teams but also the Applications teams.

## Version and Go App Pipeline Description

> Note this isn't needed for the initial version and go system. This should be a separate story spike, as it will ad a lot of complexity.

The pipeline "bootstrap" file: `Application.yaml` should perform the following...

1. References the pipeline files in the Operations repo by version tag.
2. It should use the local `Application.tf` file to "bootstrap" the template and download all needed template/module files.
3. Deploy the template it that is referenced by the `Application.tf` file using the pipeline referenced in the Ops repo.

# Risks and Unknowns

1. Local relative path used in the template to source the modules may fail if we do not copy the module files to the build agent.
2. We need to add specific functionality to the Opsineering pipeline to publish versioned artifacts.
> re: #2 we could separate this into a different pipeline.
3. We need to be able to copy the same version of pipeline files as the template.
4. We need to understand how to version using Azure Repos. 
5. We need to verify we can link to the version "tag" of the Azure Repo from the `source` property in the `Application.tf` file.

# Out-of-Scope

We are currently not including the following items.

  1. Containerization of the commands executed by the pipeline.

# Sequence Diagram

![Opsineering Version System](https://user-images.githubusercontent.com/17349002/64083850-49df4900-ccf3-11e9-9e06-af6dbb468cdc.png)

> [Web Sequence Diagram](https://www.websequencediagrams.com/) Code:
```
title Operations Version System

Ops Repo->Ops Pipeline: Build & Test
Ops Pipeline -> Artifact Stor: Publish Template Version
Ops Admin -> App Team: Send Download Link
App Team -> Artifact Stor: Request Template Version
Artifact Stor -> App Team: Download
App Team -> App Repo: Configure Template + Commit infra folder
```

![application_pipeline](https://user-images.githubusercontent.com/17349002/64084044-ff5ecc00-ccf4-11e9-8ddb-f858b335f325.png)

> [Web Sequence Diagram](https://www.websequencediagrams.com/) Code:
```
title Application Pipeline


App Pipeline->Ops Repo: Copy Request for Pipeline
Ops Repo->App Pipeline Agent: azure-pipeline.yaml and supporting files
App Pipeline Agent->App Pipeline Agent: Application.tf
App Pipeline Agent->Ops Repo: Request Template + Module files
Ops Repo->App Pipeline Agent: Template + Module files download
App Pipeline Agent->Azure: Deploy Template
```
