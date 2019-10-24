# 4. Template Testing

## 4.1 Overview

Prior to this point in the walkthrough, you deployed infrastructure by running a CIT you built yourself with guidance from the [Cobalt Templating From Scratch](./3_NEW_TEMPLATE.md) walkthrough. You also deployed infrastructure using the [*Azure Hello World CIT*](../infra/templates/az-hello-world/README.md "AZ Hello World - Cobalt Infrastructure Template") from the [Quickstart Guide](./2_QUICK_START_GUIDE.md). In other words, that's two separate experiences with the Cobalt Developer Workflow (i.e. create/choose a template ---> init ---> select workspace ---> plan ---> apply ---> destroy) and so this workflow is no longer a foreign concept.

With your new level of comfort, let's build on what you know about the Cobalt Developer Workflow and introduce the testing phases. Simply put, the Cobalt Developer Workflow described above is not considered complete without testing phases.

> *Have yet to create a Cobalt Infrastructure Template or CIT (/kɪt/) of your own? Design and create your first infrastructure template with Cobalt by completing our [Cobalt Templating From Scratch](./3_NEW_TEMPLATE.md) walkthrough.*

## 4.2 Goals and Objectives

🔲 Understand how testing fits into the SDLC for writing *CIT*s

🔲 Avoid regressions with robust unit and integration tests

🔲 Feel confident in moving forward to our next recommended section: *[Operationalizing CITs - From A to Z.. err CICD](./5_OPERATIONALIZE_TEMPLATE.md).*

## 4.3 Prerequisites
< Enumerate any prerequisite walkthroughs that should be completed prior to this, and any technical prerequisites such as developer environment / tools >

| Prereqs | Description |
|----------|--------------|
| [Quickstart Guide](./2_QUICK_START_GUIDE.md) | The quickstart guide provides all of the prerequisites you'll need to create your own *CIT* and run it.|
| [Cobalt Templating From Scratch](./3_NEW_TEMPLATE.md) | The Cobalt Templating From Scratch walkthrough provides all of the prerequisites you'll need to create your own *CIT* and run it.|
| [Terraform Modules](https://www.terraform.io/docs/configuration/modules.html) | An introductory understanding of Terraform modules.|

## 4.4 Walkthrough
< Step-by-step instructions for completing this walkthrough >