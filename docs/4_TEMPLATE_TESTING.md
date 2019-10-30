# 4. Template Testing

## 4.1 Overview

As software developers, we seek out opportunities to improve and grow projects via code contributions. Code contributions, whether major or gradual, require changes that unfortunately bring with them a chance for unexpected behavior to occur. Fortunately, automated testing grants us a chance to gain more predictability and control over the changes that occur from our contributions. Without automated testing, contributions to our codebase would simply be too unpredictable to be considered scalable.

With that being said, the task of building automated tests for infrastructure can feel a bit different then the kinds of tests you are used to. For this project, let's further build on what you've learned so far by introducing the approach Cobalt has taken to infrastructure testing and how that will impact what you know about the Cobalt Developer Workflow:

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

If you are used to writing in Terraform, you'll realize that the Cobalt Developer Workflow is the way it is because CITs are primarily written in Terraform's HCL configuration language as are the modules that they are composed of. In order to write tests in Terraform, you'll be automating this workflow. In order to make automation useful for testing, you'll have to know where in the various phases of your developer workflow would allow you to make sure your tests are isolated. You'll also have to know where it is that you can start making assertions about your CIT in an automated way. The following steps provide guidance on using your knowledge of the Cobalt Developer Workflow to properly write tests for your CIT in Terraform.

> **NOTE:** This walkthrough only focuses on running automated tests locally. Our next walkthrough *[Operationalizing CITs - A CICD Approach](./5_OPERATIONALIZE_TEMPLATE.md)* will cover ways that these automated tests can be run on code commits and various stages.

### **Step 1:** Prepare for Test Isolation

You'll want to make sure that your tests are using actual test values. The values you provide should be non-production values so as to not affect end-user environments. In the Cobalt Develop Workflow, your first opportunities to enforce isolation begins with setting up your local environment variables, running `terraform init` and then running `terraform workspace new <workspaceName>` from your CIT's directory. You'll be automating this, so make sure you have those values ready.

1. Ensure that your .env file is using non-production values and take note of them.

2. Ensure that the workspaceName that gets created on each dev workflow cycle is unique enough to allow for tests to ru in parallel. It's very possible that you are on a team with dev who have to share cloud provider resources and account. The workspace name may be your solution to working in isolation from other devs.

3. Local the input variables in your CIT that further help you achieve test isolation. Here are a few examples of required input values we used to help enforce isolation for our az-hello-world CIT. - *More on Input Variables:* https://www.terraform.io/docs/configuration/variables.html

    | Input Variable Name | Value | Description |
    |--------|----------|-----------|
    | `workspace` | "az-hello-world-" + guid | It's important that a random guid is attached to the workspace of your tests as that enables unique workspaces ensuring that tests can be run in parallel. |
    |  `prefix`  | "az-hw-unit-tst-" + guid | A prefix name for appending unique values to resources that require a unique name. Helpful for integration tests as those kinds of tests create actual infrastructure.|
    | `storage_account_name`  | os.Getenv("TF_VAR_remote_state_account") | It's important that these tests run in isolation and do not impact production environments, therefore, this value should be the storage account dedicated to the dev environment. |
