# 4. Template Testing

## 4.1 Overview

Because we haven't introduced the concept of what it means to test a Cobalt Infrastructure Template, on two separate occasions we set you up to get away with deploying infrastructure without any mention of creating or running tests. You deployed infrastructure by running a CIT you built yourself with guidance from the [Cobalt Templating From Scratch](./3_NEW_TEMPLATE.md) walkthrough. You also deployed infrastructure using the [*Azure Hello World CIT*](../infra/templates/az-hello-world/README.md "AZ Hello World - Cobalt Infrastructure Template") from the [Quickstart Guide](./2_QUICK_START_GUIDE.md). Simply put, you've had two experiences with the Cobalt Developer Workflow (i.e. create/choose a template ---> init ---> select workspace ---> plan ---> apply ---> destroy) that did not include testing. Let's further build on what you know so far by surfacing the approach Cobalt has taken to infrastructure testing and how that will impact the Cobalt Developer Workflow.

> *Have yet to create a Cobalt Infrastructure Template or CIT (/kɪt/) of your own? Design and create your first infrastructure template with Cobalt by completing our [Cobalt Templating From Scratch](./3_NEW_TEMPLATE.md) walkthrough.*

## 4.2 Goals and Objectives

🔲 Understand how testing fits into the SDLC for writing *CIT*s

🔲 Avoid regressions with robust unit and integration tests

🔲 Feel confident in moving forward to our next recommended section: *[Operationalizing CITs - CICD Templates](./5_OPERATIONALIZE_TEMPLATE.md).*

## 4.3 Prerequisites

| Prereqs | Description |
|----------|--------------|
| [Quickstart Guide](./2_QUICK_START_GUIDE.md) | This should have served as your first Cobalt Infrastructure deployment. |
| [Cobalt Templating From Scratch](./3_NEW_TEMPLATE.md) | Completing this prequisite leaves you with a CIT and prior knowledge needed for this walkthrough. |
| [Terraform Modules](https://www.terraform.io/docs/configuration/modules.html) | An introductory understanding of Terraform modules.|
| [Go](Golang) | An introductory understanding of Go. |
| [Go Test](Golang) | An introductory understanding of Go Tests |
| [TerraTest](Gruntworks) | An introductory understanding of TerraTest |

## 4.4 Walkthrough - Test a Cobalt Infrastructure Template

< Step-by-step instructions for completing this walkthrough >