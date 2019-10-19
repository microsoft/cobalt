# 3. Cobalt Templating From Scratch

## 3.1 Overview

Per the [quickstart guide](./2_QUICK_START_GUIDE.md), we demonstrated that you can get pretty far with *Cobalt* by simply relying on any out of the box *Cobalt Infrastructure Template* or *CIT* (/kɪt/). However, for several reasons, you may very well have unique infrastructure scenarios that require you to extract more use out of *Cobalt*. Therefore, we recommend building a *Cobalt Infrastructure Template* from scratch in order to cultivate a deeper understanding of what *Cobalt* has to offer.

A major core feature of *Cobalt* is that it offers a library of Terraform based *Cobalt Module*s that allow you to create and build-up *CIT*s. The act of creating a *CIT* from scratch will almost always involve thoughtfully choosing a mix of *Cobalt Module*s that already exist or were created by you. This section of the walkthrough will be an exercise in building *CIT*s for Cobalt. Happy templating! 😄

> *Have you completed the quickstart guide? Deploy your first infrastructure as code project with Cobalt by following the [quickstart guide](./2_QUICK_START_GUIDE.md).*

## 3.2 Goals and Objectives

🔲 Demonstrate how to create *Cobalt Modules* and *CIT*s that work for your custom infrastructure scenario.

🔲 Improve your understanding of how to use existing *Cobalt Module*s and *CIT*s so that they can better work for you.

🔲 Feel confident in moving forward to our next recommended section: *[Testing Cobalt Templates](./4_TEMPLATE_TESTING.md).*

## 3.3 Prerequisites

| Prereqs | Description |
|----------|--------------|
| [Quickstart Guide](./2_QUICK_START_GUIDE.md) | The quickstart guide provides all of the prerequisites you'll need to create your own *CIT* and run it.|
| [Terraform Modules](https://www.terraform.io/docs/configuration/modules.html) | An introductory understanding of Terraform modules.|

## 3.4 Create and Run a New Template

*Cobalt Module*s primarily rely on [Terraform Modules](https://www.terraform.io/docs/configuration/modules.html). The primary purpose of a Terraform Module as a feature is to encapsulate parts of your potential infrastructure configuration into reusable units.

Here's a great example of Cobalt's existing [Azure service-plan](./../infra/modules/providers/azure/service-plan/README.md) module. It's being reused by several out of the box CIT's.

| Cobalt Module | Module Anatomy | Cobalt Infrastructure Template Using The Module |
|----------|----------|----------|
| Azure service-plan | pending png | pending png |

The above table demonstrates in a clear way how *Cobalt Infrastructure Templates* reap the natural benefits of the reusability that's offered by *Cobalt Modules*. Terraform modules grant *Cobalt modules* this feature. Let's experience what it's like to create your own *CIT* from scratch by following the below steps:

### **Step 1:** Model your planned infrastructure

| New CIT Name | Description | Deployment Goal |
|----------|----------|----------|
| **az-hello-world-from-scratch** | A Cobalt Infrastructue Template that when ran creates a basic [Azure Function App](https://docs.microsoft.com/en-us/azure/azure-functions/functions-overview) within an [App Service Plan](https://docs.microsoft.com/en-us/azure/app-service/overview-hosting-plans) accompanied with [Azure Storage](https://azure.microsoft.com/en-us/services/storage/blobs/). | <image src="https://user-images.githubusercontent.com/10041279/67136958-a9d27600-f1f3-11e9-896c-d18f3a287de5.png" width="400" height="150"/> |

For demonstration purposes, we have already modeled the infrastructure. You will build a *CIT* and title it **az-hello-world-from-scratch** within your codebase. This CIT when ran will create and deploy the Azure resources listed in the description of the above table.

### **Step 2:** Decide if any new Cobalt Modules need to created

When the decision of which infrastructure resources to deploy has been made, the next question is, "Does Cobalt have existing reusuable modules configured for any of my infrastructure resources?".

At the time of this walkthrough, there are reusable modules that encapsulate infrastructure configurations for an Azure App Service Plan and Azure Storage, so you will use those to build part of your *CIT*. However, there is no current *Cobalt Module* configured for deploying Azure Functions. So, yes, a new Cobalt Module needs to be created. Let's design one!

### **Step 2:** Design a Terraform Based *Cobalt Module*

Cobalt Modules and Cobalt Infrastructure Templates are both primarely written using Terraform's [HCL language](https://learn.hashicorp.com/terraform), a language that grants us the ability to target multiple multiple cloud providers. The HCL language has documentation partitioned by cloud provider. We are targeting Azure from our template, therefore, we used Terraform's documentation on Azure's ARM provider for guidance on how to design an Azure Function Cobalt Module.

You will become very familiar with Terraform's documentation as you learned to use and build your own modules and CITs.

### **Step 3:** Implement your chosen custom Terraform Based *Cobalt Module*s

.....

### **Step 4:** Create a CIT that references your mix of Cobalt Modules

| New CIT Name | CIT Anatomy |
|----------|----------|
| az-hello-world-from-scratch |

### **Step 5:** Setup Local Environment Variables


### **Step 6:** Initialize a Terraform Remote Workspace


### **Step 7:** Run Your New Template


### **Step 8:** Validate Infrastructure Deployed Successfully


### **Final Step:** Teardown Infrastructure Resources


## Conclusion

As both the CITs and the Cobalt Modules that they are composed of continue to grow and become more robust, we welcome your contributions. *[A Link to contribution guidelines](pending)*

### **Recommended Next Step:** *[Testing Cobalt Templates](./4_TEMPLATE_TESTING.md).*
