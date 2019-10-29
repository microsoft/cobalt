# 4. Template Testing

## 4.1 Overview

As software developers, we seek out opportunities to improve and grow projects via code contributions. Code contributions, whether major or gradual, require changes that unfortunately bring with them a chance for unexpected behavior to occur. Fortunately, automated testing grants us a chance to gain more predictability and control over the changes that occur from our contributions. Without automated testing, contributions to our codebase would simply be too unpredictable to be considered scalable.

With that being said, the task of building automated tests can vary from software project to project. For this project, let's further build on what you've learned so far by introducing the approach Cobalt has taken to infrastructure testing and how that will impact what you know about the Cobalt Developer Workflow:

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
| [Go Test](Golang) | An introductory understanding of Go Tests. |
| [TerraTest](Gruntworks) | An introductory understanding of TerraTest. |
| [Docker](Docker.io) | An introductory understanding of Docker. |

## 4.4 Walkthrough - Testing a Cobalt Infrastructure Template (CIT)

CIT's are primarily written in Terraform's HCL configuration language as are the modules that they are composed of. Therefore, they are made up of the same properties that make up modules. The following steps provide guidance on using your knowledge of these Terraform properties to properly write tests in Terraform.

> **NOTE:** This walkthrough only focuses on running automated tests locally. Our next section *[Operationalizing CITs - A CICD Approach](./5_OPERATIONALIZE_TEMPLATE.md)* will cover ways that these automated tests can be run on code commits and various stages.

### **Step 1:** Choose which properties of the CIT you care about testing

Testing a Cobalt Infrastructure Template begins with the exercise of walking through the commonly shared properties that all CITs are made of (i.e. input variables, output variables, provider blocks, resource blocks, other modules and more) and carefully thinking about their impact on that CIT's Terraform state along with it's deployed infrastructure during the plan, apply and destroy phases of the Cobalt Developer Workflow. This exercise will assist you in developing assertions that you care about testing in relation to your CIT.

1. Choose Input Variables For Testing - *More on Input Variables:* https://www.terraform.io/docs/configuration/variables.html

    Decide on the test values to use when running tests. The values you provide should be non-production values so as to not affect end-user environments. Here are a few examples of test values we used as input for our az-hello-world CIT:

2. Choosing Output Variables For Testing - *More on Input Variables:* https://www.terraform.io/docs/configuration/outputs.html

    Outputs are return values for modules, therefore, your CIT also has return values. Outputs are great candidates for testing because they explicitly are visibile within your Terraform Plan. Here are a few examples of the assertions we decided to test for our az-hello-world CIT:
