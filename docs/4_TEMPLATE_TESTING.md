# 4. Template Testing

## 4.1 Overview

As software developers, we seek out opportunities to grow and improve the codebase. Growth and improvement, whether major or gradual, requires change and all changes bring with them a chance for unexpected behavior to occur. Automated testing is chance for us to gain more predictability and control over the outcomes of those changes. Without automated tests, our codebase will simply be too unpredictable to be considered scalable. With that being said, the task of building automated test can vary from project to project. For this project, let's further build on what you've learned so far by introducing the recommended approach Cobalt has taken to infrastructure testing and how that will impact the Cobalt Developer Workflow:

> *Have yet to create a Cobalt Infrastructure Template or CIT (/kɪt/) of your own? Design and create your first infrastructure template with Cobalt by completing our [Cobalt Templating From Scratch](./3_NEW_TEMPLATE.md) walkthrough.*

## 4.2 Goals and Objectives

🔲 Understand how testing fits into the SDLC for writing *CIT*s

🔲 Avoid regressions with robust unit and integration tests

🔲 Feel confident in moving forward to our next recommended section: *[Operationalizing CITs - A CICD Approach](./5_OPERATIONALIZE_TEMPLATE.md)*

## 4.3 Prerequisites

| Prereqs | Description |
|----------|--------------|
| [Quickstart Guide](./2_QUICK_START_GUIDE.md) | This should have served as your first Cobalt Infrastructure deployment. |
| [Cobalt Templating From Scratch](./3_NEW_TEMPLATE.md) | Completing this prequisite leaves you with a CIT and prior knowledge needed for this walkthrough. |
| [Terraform Modules](https://www.terraform.io/docs/configuration/modules.html) | An introductory understanding of Terraform modules.|
| [Go](Golang) | An introductory understanding of Go. |
| [Go Test](Golang) | An introductory understanding of Go Tests |
| [TerraTest](Gruntworks) | An introductory understanding of TerraTest |
| [Docker](Docker.io) | An introductory understanding of Docker |

## 4.4 Walkthrough - Testing a Cobalt Infrastructure Template

### **Step 1:** Code to the Terraform Harness Hooks - Unit Testing

### **Step 2:** Code to the Terraform Harness Hooks - Integration Testing
