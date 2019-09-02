# Version and Go Technical Design Purpose

This design addresses Cobalt's workflow to deploy individual application infrastructure using a Cobalt template.

## Definitions
 - `Engineering Team (Eng Team)` - DevOps or Operations team consisting of Infrastructure Administrators or similar roles.
 - `Application Team (App Team)` - Software Developers with an application to deploy to Azure.
 - `Development Repo (Dev Repo)` - Cobalt's repo hosted on Github at [https://github.com/microsoft/cobal](https://github.com/microsoft/cobal)
 - `Engineering Repo (Eng Repo)` - Individual template repository managed by the `Engineering Team`
 - `Application Repo (App Repo)` - Repository that contains the application code to be deployed and managed by the `Application Team`

## Version and Go Setup Description
Our design starts after the initial Cobalt setup, where an individual template is cloned into an organizations source control (ref: [Setup Doc]()). An application development team is ready to start deploying their code to infrastructure built in Azure. Typically they would make a request to the engineering team. The Eng team would provide the App team with a link to the latest infra configuration files for a specific template. The App team downloads this tar/zip file and extracts the folder/files.

```
infra/
 |_ Application.tf
 |_ Application.yaml
```

 - `Appliation.tf` is the artifact that points to the template in the eng repo. The application team would need to fill this file out with the requested configuration. Example:

 ```
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

 - `Application.yaml` - is the artifact that points to the azure-pipeline.yml file in the eng repo that contains the build/test/deploy pipeline.

This folder/files should be checked into the root of the app repo. The Eng team would then configure the pipeline to point to these files and deploy the requested infrastructure.

## Version and Go Pipeline Description

The pipeline "bootstrap" file: `Application.yaml` should perform the following...

1. Request to copy the pipeline files down to the build agent from the engineering repo.
2. It should use the local `Application.tf` file to "bootstrap" the template and download all needed template/module files.
3. Deploy the template it that is referenced by the `Application.tf` file.

# Risks and Unknowns

1. Local relative path used in the template to source the modules may fail if we do not copy the module files to the build agent.
2. We need to add specific functionality to the engineering pipeline to publish versioned artifacts.
3. We need to be able to copy the same version of pipeline files as the template.
4. We need to configure the pipeline to use `Application.tf` not template `main.tf ` to deploy from the app repo.
5. We need to understand how to version using Azure Repos. 
6. We need to verify we can link to the version "tag" of the Azure Repo from the `source` property in the `Application.tf` file.

# Out-of-Scope

We are currently not including the following items in the creating of this module.

  1. Containerization of the commands executed by the pipeline.

# Sequence Diagram

![Engineering Version System](https://user-images.githubusercontent.com/17349002/64083850-49df4900-ccf3-11e9-9e06-af6dbb468cdc.png)

> [Web Sequence Diagram](https://www.websequencediagrams.com/) Code:
```
title Engineering Version System

Eng Repo->Eng Pipeline: Build & Test
Eng Pipeline -> Artifact Stor: Publish Template Version
Eng Admin -> App Team: Send Download Link
App Team -> Artifact Stor: Request Template Version
Artifact Stor -> App Team: Download
App Team -> App Repo: Configure Template + Commit infra folder
```

![application_pipeline](https://user-images.githubusercontent.com/17349002/64084044-ff5ecc00-ccf4-11e9-8ddb-f858b335f325.png)

> [Web Sequence Diagram](https://www.websequencediagrams.com/) Code:
```
title Application Pipeline


App Pipeline->Eng Repo: Copy Request for Pipeline
Eng Repo->App Pipeline Agent: azure-pipeline.yaml and supporting files
App Pipeline Agent->App Pipeline Agent: Application.tf
App Pipeline Agent->Eng Repo: Request Template + Module files
Eng Repo->App Pipeline Agent: Template + Module files download
App Pipeline Agent->Azure: Deploy Template
```
