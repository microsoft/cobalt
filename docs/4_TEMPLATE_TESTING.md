# 4. Template Testing

## 4.1 Overview

Previously, to keep things simple, our walkthroughs set you up to deploy infrastructure without creating or running tests. Using the guidance from our [Cobalt Templating From Scratch](./3_NEW_TEMPLATE.md) walkthrough, you deployed infrastructure by running a CIT you built yourself. Using the [Quickstart Guide](./2_QUICK_START_GUIDE.md) you deployed infrastructure by running our [*Azure Hello World CIT*](../infra/templates/az-hello-world/README.md "AZ Hello World - Cobalt Infrastructure Template").

Simply put, you've had two experiences with the Cobalt Developer Workflow (i.e. create/choose a template ---> init ---> select workspace ---> plan ---> apply ---> destroy) that did not include testing. However, we strongly encourage testing as a part of your dev worklflow. The reason is ...

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

### **Step 1:** Use Test Harness Feature
