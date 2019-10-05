# 2. Quick Start Guide

## 2.1 Overview

*Cobalt* is a tool for developers who are interested in reusing or contributing new cloud infrastructure as code patterns in template form. An actualized infrastructure as code pattern in Cobalt is called a *Cobalt Infrastructure Template* or *CIT* (/kɪt/). Cobalt Infrastructure Templates rely on *Terraform* as the scripting language of choice.

You can get pretty creative and build your own custom *CIT*s in order to use and/or contribute to Cobalt but we strongly recommend that you first complete this quick start guide. This guide is centered around our existing [*Azure Hello World CIT*](../infra/templates/az-hello-world/README.md "AZ Hello World - Cobalt Infrastructure Template") and should serve as your first Azure infrastructure deployment. In summary, completing this guide should be your first major step in familiarizing yourself with Cobalt and the *CIT* developer workflow. Happy templating! 😄

> For a more general overview of Cobalt, please visit our main page: [READ ME](https://github.com/microsoft/cobalt/blob/master/README.md "Main Cobalt Read Me")

## 2.2 Goals and Objectives

🔲 Prepare local environment for *Cobalt Infrastructure Template* deployments.

🔲 Deploy the [*Azure Hello World CIT*](../infra/templates/az-hello-world/README.md "AZ Hello World - Cobalt Infrastructure Template").

🔲 Walk away with a introductory understanding of the *CIT* developer workflow.

🔲 Feel confident in moving forward to our next recommended section: *[Cobalt Templating from Scratch](https://github.com/microsoft/cobalt/blob/master/docs/3_NEW_TEMPLATE.md).*

## 2.3 Prerequisites

* App dev experience (prev. "infrastructure as code" experience not required)
* An Azure Subscription
  * [Azure Portal](https://portal.azure.com/) - This template needs to deploy infrastructure within an Azure subscription.
* An Azure Service Principal
  * [Azure Service Principal](https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal) - This template needs permissions to deploy infrastructure within an Azure sbuscription.
* An Azure Storage Account
  * [Azure Storage Account](https://docs.microsoft.com/en-us/azure/storage/common/storage-account-overview) - An account for tracking terraform remote backend state. You can use our backend state setup [template](../infra/templates/backend-state-setup/README.md) to provision the storage resources.
* Terminal with bash shell
  * [WSL](https://code.visualstudio.com/docs/remote/wsl) or [Git Bash](https://git-scm.com/downloads) - The shell environment needed to follow along with the provided instructions.
* Local environment
  * [Local environment setup](https://github.com/microsoft/cobalt/tree/master/test-harness#local-environment-setup)
* Git Source Control
  * [Install git](https://www.atlassian.com/git/tutorials/install-git)
* Local Terrafrom
  * [Install Terraform](https://learn.hashicorp.com/terraform/getting-started/install.html)
* Azure CLI
  * [Get started with Azure CLI](https://docs.microsoft.com/en-us/cli/azure/get-started-with-azure-cli?view=azure-cli-latest)

---

## 2.4 Walkthrough

> ### **Deploying [_Azure Hello World CIT_](../infra/templates/az-hello-world/README.md)**
> ![Cobalt Sample Gif](https://media.giphy.com/media/TJVF0piXxS1o4V44OD/giphy.gif)
<!--- These gifs will have screenshots from forking, terraform plan and apply, visit azure portal and visit app service url --->


**STEP 1:** Setup Environment Variables

- You'll need to define a `.env` file in the root of the project. You can use our [environment template file](https://github.com/microsoft/cobalt/blob/master/.env.template) to start. `cp .env.template .env`
- Provide values for the environment values in `.env` which are required to authenticate Terraform to provision resources within your subscription.

```bash
ARM_SUBSCRIPTION_ID="<az-service-principal-subscription-id>"
ARM_CLIENT_ID="<az-service-principal-client-id>"
ARM_CLIENT_SECRET="<az-service-principal-auth-secret>"
ARM_TENANT_ID="<az-service-principal-tenant>"
ARM_ACCESS_KEY="<remote-state-storage-account-primary-key>"
TF_VAR_remote_state_account="<tf-remote-state-storage-account-name>"
TF_VAR_remote_state_container="<tf-remote-state-storage-container-name>"
```