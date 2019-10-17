# 3. Cobalt Templating From Scratch

## 3.1 Overview

Per the [quickstart guide](./2_QUICK_START_GUIDE.md), we demonstrated that you can get pretty far with *Cobalt* by simply relying on the out of the box *CIT*s (/kɪt/). However, for several reasons, you may very well have desirable infrastructure experiments you'd like to run that require you to get more use out of *Cobalt*. Therefore, we recommend completing this section in order to learn what it's like to build a *Cobalt Infrastructure Template* from scratch. Happy templating! 😄

> *Have you completed the quick start guide? Deploy your first infrastructure as code project with Cobalt by following the [quickstart guide](./2_QUICK_START_GUIDE.md).*

## 3.2 Goals and Objectives

🔲 Provide you deeper insight into how to configure existing *CIT*s and *Cobalt Module*s to work for you.

🔲 Shine a brighter light on the potential of Cobalt.

🔲 Feel prepared to create *Cobalt Modules* and *CIT*s that you can use and share via contributions to Cobalt: *[A Link to contribution guidelines](pending).*

🔲 Feel confident in moving forward to our next recommended section: *[Testing Cobalt Templates](./4_TEMPLATE_TESTING.md).*

## 3.3 Prerequisites

| Prereqs | Description |
|----------|--------------|
| Quickstart Guide |[Quickstart Guide](./2_QUICK_START_GUIDE.md) - The quickstart guide provides all of the prerequisites you'll need to create your own CIT and run it.|

## 3.4 Create A New Template and Run it

A major core feature of *Cobalt* is that it offers a library of Terraform based *Cobalt Module*s that allow you to create and build-up *Cobalt Infrastructure Template*s or *CIT*s. Creating a *CIT* from scratch is done by thoughtfully choosing a mix of *Cobalt Modules* that already exist or were created by you. Experience what it's like to create your own *CIT* from scratch by following the below steps:

| CIT Anatomy | Module Anatomy |
|----------|--------------|
|`pending`|`pending`|


### **Step 1:** Build a Terraform Based *Cobalt Module*

*Cobalt Module*s primarily rely on [*Terraform*](https://learn.hashicorp.com/terraform)'s HCL language in order to target a wide array of cloud providers. They are used as inputs to Terraform templates.

### **Step 2:** Choose other *Cobalt Module*s


### **Step 3:** Create a CIT that references the Cobalt Modules


### **Step 4:** Setup Local Environment Variables


### **Step 5:** Initialize a Terraform Remote Workspace


### **Step 6:** Run Your New Template


### **Step 7:** Validate Infrastructure Deployed Successfully


### **Final Step:** Teardown Infrastructure Resources


## Conclusion

As both the CITs and the Cobalt Modules that they are composed of continue to grow and become more robust, we welcome your contributions.

### **Recommended Next Step:** *[Testing Cobalt Templates](./4_TEMPLATE_TESTING.md).*
