# 3. Cobalt Templating From Scratch

## 3.1 Overview

Per the [quickstart guide](./2_QUICK_START_GUIDE.md), we demonstrated that you can get pretty far with *Cobalt* by simply relying on any out of the box *Cobalt Infrastructure Template* or *CIT* (/kɪt/). However, for several reasons, you may very well have unique infrastructure scenarios that require you to extract more use out of *Cobalt*. Therefore, we recommend building a *Cobalt Infrastructure Template* from scratch in order to cultivate a deeper understanding of what *Cobalt* has to offer. Happy templating! 😄

> *Have you completed the quickstart guide? Deploy your first infrastructure as code project with Cobalt by following the [quickstart guide](./2_QUICK_START_GUIDE.md).*

## 3.2 Goals and Objectives

🔲 Demonstrate how to create *Cobalt Modules* and *CIT*s that work for your custom infrastructure scenario.

🔲 Improve your understanding of how to use existing *Cobalt Module*s and *CIT*s so that they can better work for you.

🔲 Feel confident in moving forward to our next recommended section: *[Testing Cobalt Templates](./4_TEMPLATE_TESTING.md).*

## 3.3 Prerequisites

| Prereqs | Description |
|----------|--------------|
| [Quickstart Guide](./2_QUICK_START_GUIDE.md) | The quickstart guide provides all of the prerequisites you'll need to create your own *CIT* and run it.|

## 3.4 Create and Run a New Template

A major core feature of *Cobalt* is that it offers a library of Terraform based *Cobalt Module*s that allow you to create and build-up *CIT*s. Creating a *CIT* from scratch is done by thoughtfully choosing a mix of *Cobalt Modules* that already exist or were created by you. Experience what it's like to create your own *CIT* from scratch by following our guidance from the below steps:

| Infrastructure Scenario | Description | Deployment Goal |
|----------|----------|----------|
| Azure Template A | pending | `pending`

### **Step 1:** Build a Terraform Based *Cobalt Module*

*Cobalt Module*s primarily rely on [*Terraform*](https://learn.hashicorp.com/terraform)'s HCL language in order to target a wide array of cloud providers. They are used as inputs to Terraform templates.

| Infrastructure Scenario | Module Anatomy |
|----------|----------|
| Azure Template A | pending |

### **Step 2:** Choose other *Cobalt Module*s


### **Step 3:** Create a CIT that references the Cobalt Modules

| Infrastructure Scenario | CIT Anatomy |
|----------|----------|
| Azure Template A | pending |

### **Step 4:** Setup Local Environment Variables


### **Step 5:** Initialize a Terraform Remote Workspace


### **Step 6:** Run Your New Template


### **Step 7:** Validate Infrastructure Deployed Successfully


### **Final Step:** Teardown Infrastructure Resources


## Conclusion

As both the CITs and the Cobalt Modules that they are composed of continue to grow and become more robust, we welcome your contributions. *[A Link to contribution guidelines](pending)*

### **Recommended Next Step:** *[Testing Cobalt Templates](./4_TEMPLATE_TESTING.md).*
