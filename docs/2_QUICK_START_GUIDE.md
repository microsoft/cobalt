# 2. Quick Start Guide

## 2.1 Overview

**C**obalt is a tool for developers who are interested in reusing or contributing new cloud infrastructure as code patterns in template form. An actualized infrastructure as code pattern in Cobalt is called a *Cobalt Infrastructure Template* or *CIT* (/kɪt/), a template written in *Terraform* as the language of choice.

Although you can get pretty creative and build your own custom CIT in order to use and/or contribute to Cobalt, we strongly recommend completing this quick start guide, a guide which reuses our existing [*Azure Hello World CIT*](../infra/templates/az-hello-world/README.md) for your first infrastructure deployment. Completing this guide should be the first major step in familiarizing yourself with Cobalt and the CIT developer workflow. Happy templating!

For more general information about Cobalt, please visit our main page: [READ ME](../README.md)

## 2.2 Goals and Objectives

- Use the [*Azure Hello World CIT*](../infra/templates/az-hello-world/README.md) as an introductory template for provisioning your Azure resources
- Walk away with a introductory understanding of the CIT developer workflow
- Feel confident in moving forward to our next recommended section: *[Cobalt Templating from Scratch](./3_NEW_TEMPLATE.md).*

## 2.3 Prerequisites

  * App dev experience (Previous "Infrastructure as Code" experience not required)
  * An Azure Subscription
  * A [service principal](https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal)
  * An Azure Storage Account for tracking terraform remote backend state. You can use our backend state setup [template](../infra/templates/backend-state-setup/README.md) to provision the storage resources.
  * WSL or Bash
  * Local environment [setup](https://github.com/microsoft/cobalt/tree/master/test-harness#local-environment-setup)
  * Install [git](https://www.atlassian.com/git/tutorials/install-git)
  * Install [Terraform](https://learn.hashicorp.com/terraform/getting-started/install.html)
  * Azure CLI
    * [Get started with Azure CLI](https://docs.microsoft.com/en-us/cli/azure/get-started-with-azure-cli?view=azure-cli-latest)

## 2.4 Walkthrough

<!--- These gifs will have screenshots from forking, terraform plan and apply, visit azure portal and visit app service url --->
> ![Cobalt Sample Gif](https://media.giphy.com/media/TJVF0piXxS1o4V44OD/giphy.gif)


< Step-by-step instructions for completing this walkthrough >