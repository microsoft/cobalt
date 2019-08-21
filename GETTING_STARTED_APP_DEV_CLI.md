# Getting Started - Application Developer - Azure CLI

[[_TOC_]]

## Overview

This section provides application developers wishing to host solutions on Cobalt templates recommendations for building their infrastructure-as-code repository and accompanying CI/CD pipelines. It assumes an isolated Azure DevOps Project with a Cobalt template Repo and Build Pipeline has already been created as defined in the [Getting Started - Advocated Pattern Owner](./GETTING_STARTED_ADD_PAT_OWNER.md) walkthrough.

## Prerequisites

* Azure CLI
  * [Get started with Azure CLI](https://docs.microsoft.com/en-us/cli/azure/get-started-with-azure-cli?view=azure-cli-latest)
* Azure DevOps CLI extension
  * [Get started with Azure DevOps CLI](https://docs.microsoft.com/en-us/azure/devops/cli/get-started?view=azure-devops)
* Existing repository and CI/CD pipeline for desired Cobalt template 
  * [Getting Started - Advocated Pattern Owner](./GETTING_STARTED_ADD_PAT_OWNER.md)

## Steps

1. [Setup your application's Azure DevOps Project](#setup-your-application-azure-devops-project)
2. [Import Cobalt template for your appliation to your Azure DevOps Repo](#import-cobalt-template-for-your-application-to-your-azure-devops-repo)
3. [Create Azure DevOps Build Pipeline for your application infrastructure](#create-azure-devops-build-pipeline-for-your-application-infrastructure)
4. [Verify successfull infrastructure deployment](#verify-successful-infrastructure-deployment)

### Setup your application Azure DevOps Project

#### (Optional) Create a new Project

[Return to Steps](#steps)

### Import Cobalt template for your application to your Azure DevOps Repo

#### Modify Cobalt template variables for your application

[Return to Steps](#steps)

### Create Azure DevOps Build Pipeline for your application infrastructure

[Return to Steps](#steps)

### Verify successful infrastructure deployment

[Return to Steps](#steps)

## Outcomes

After completing these steps, you should have an Azure DevOps Project for your application that contains:
* An Azure DevOps Repo for your application's Cobalt template infrastructure
* An Azure DevOps Build CI/CD Pipeline for your application's Cobalt template infrastructure including successful deployment and provisioning of template resources

## Additional Recommendations

We recommend creating a separate repository in the same shared application project for your application code. Additionally, an application CI / CD build pipeline should be created to manage the application. The application project will then have two pillars -- one supporting the Cobalt template infrastructure configuration specific to the application, and one supporting the application development.
