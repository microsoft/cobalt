# 3. Cobalt Templating From Scratch

## 3.1 Overview

Per the [quickstart guide](./2_QUICK_START_GUIDE.md), we demonstrated that you can get pretty far with *Cobalt* by simply relying on any out of the box *Cobalt Infrastructure Template* or *CIT* (/kɪt/). However, for several reasons, you may very well have unique infrastructure scenarios that require you to extract more use out of *Cobalt*. Therefore, we recommend building a *Cobalt Infrastructure Template* from scratch in order to cultivate a deeper understanding of what *Cobalt* has to offer. 

A major core feature of *Cobalt* is that it offers a library of Terraform based *Cobalt Module*s that allow you to create and build-up *CIT*s. Creating a *CIT* from scratch is done by thoughtfully choosing a mix of *Cobalt Module*s that already exist or were created by you. Happy templating! 😄

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

*Cobalt Module*s primarily rely on [*Terraform Modules*](https://www.terraform.io/docs/configuration/modules.html). The primary purpose of a Terraform Module as a feature is to encase parts of your potential infrastructure configuration into reusable units. Other benefits include readability and a code base that's easier to manage.

Here's a great example of Cobalt's existing [Azure service-plan](./../infra/modules/providers/azure/service-plan/README.md) module. It's being reused by several out of the box CIT's.

| Cobalt Module | Module Anatomy | Separate Cobalt Templates Referencing The Azure Service-plan Module | 
|----------|----------|----------|
| Azure service-plan | pending png | pending png |

The above table demonstrates in a clear way how *Cobalt Module*s reap the natural benefits of the reusability that's core to Terraform Modules. Let's Experience what it's like to create your own *CIT* from scratch that is composed of a mix of Cobalt Modules by following along with the below steps:

| New CIT Name | Description | Deployment Goal |
|----------|----------|----------|
| az-hello-world-from-scratch | A Cobalt Infrastructue Template that when ran deploys a basic Azure Function app and Azure Storage within an Azure Resource Group. | ![image](https://user-images.githubusercontent.com/10041279/67122916-7fad9380-f1b4-11e9-8d4a-bc32fe48158d.png) |

### **Step 1:** Design a mix of Terraform Based *Cobalt Module*s

Terraform Modules are written using Terraform's [HCL language](https://learn.hashicorp.com/terraform), a language that grants us the ability to target multiple multiple cloud providers...

### **Step 2:** Build your chosen custom Terraform Based *Cobalt Module*s


### **Step 3:** Create a CIT that references your mix of Cobalt Modules

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
