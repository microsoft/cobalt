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

If you are used to developing in Terraform, you'll realize that the Cobalt Developer Workflow is the way it is because CITs are primarily written in Terraform's HCL configuration language as are the modules that they are composed of. Executing this workflow so far has required you to interact with Terraform via it's cli. However, you might not have known that the Terraform cli runs commands against [Terraform Core](https://www.terraform.io/docs/extend/how-terraform-works.html#terraform-core), a statically compiled Golang binary. Therefore, in order to programmatically interact with Terraform to achieve automation, you'll have to write tests in Golang.

Furthermore, in order to make automation useful for testing, you'll have to know where in the various phases of your developer workflow enable test isolation. You'll also have to know where it is that you can start making assertions about your CIT's deployment plans and the infrastructure that was stood up in an automated way. The following steps provide guidance on using your knowledge of the Cobalt Developer Workflow to properly write automated test in Golang for your CIT.

> **NOTE:** This walkthrough only focuses on running automated tests locally. Our next walkthrough *[Operationalizing CITs - A CICD Approach](./5_OPERATIONALIZE_TEMPLATE.md)* will cover ways that these automated tests can be run on code commits and various stages.

### **Step 1:** Prepare for Test Isolation

You'll want to make sure that your tests are using actual test values before programmatically running `terraform plan`. The values you provide should be non-production values so as to not affect end-user environments. In the Cobalt Develop Workflow, the opportunities to enforce test isolation first begin with setting up your local environment variables, and then running `terraform init` and `terraform workspace new <workspaceName>` from your CIT's directory.

> **NOTE:** Due to the beginning of the Cobalt Developer Workflow having a hard dependency on a back-end state file, both unit testing and integration testing will need these environment variables. Therefore, we recommend making these decisions early-on as a first step.

1. Prepare your environment variables. Ensure that your .env file is using non-production values as you will be referencing these when writing your automated tests. These values are usually specific to the provider your CIT is targeting. Here are a few examples:

    | Env Variables | Test Value | Description |
    |--------|----------|-----------|
    | `storage_account_name`  | Value from "TF_VAR_remote_state_account" | This value should be the storage account dedicated to the dev environment. The value lives within your .env file |
    | `container_name`  | Value from "TF_VAR_remote_state_container" | This value will be the dedicated container that will holder multiple backend remote workspace terraform state files. The value lives within your .env file . |

2. Locate the input variables from your CIT that further help you achieve test isolation and choose values for them. Here are all the input variables and values we used to help further prepare the az-hello-world CIT for test isolation:

    > **NOTE:** The az-hello-world CIT relies on a commons.tf file that enforces uniqueness of resource names for varying reasons, therefore, the names you choose below will be further transformed based on the implementation of the commons.tf file. Some of the reasons for the name transformations include work isolation and other reasons are due to resources that require unique names like fqdns.

    | Input Var Name | Test Value | Description |
    |--------|----------|-----------|
    | `workspace` | "az-hello-world-" + guid | It's important that a random guid is attached to the workspace of your tests. Teams share cloud provider resources and accounts. The workspace name may be your only solution to working in isolation from other devs on your team. |
    |  `name`  | "az-hw-unit-tst-" + guid | A prefix name for appending unique values to resources that require a unique name. Helpful for integration tests as those kinds of tests create actual infrastructure.|
    | `resource_group_location`  | "eastus" | The geo-location of the Azure datacenter in which you want the resource group that contains your infrastructure to live. A geo-location maybe different then production. |

### **Step 2:** Develop Your Terraform Plan Based Assertions (Unit Testing)

The previous step properly prepared you for test isolation. Now you can concern yourself with the business of developing assertions. The best way to make assertions about your CIT is to rely on what's visible in the Terraform Plan. Terraform Plans are what's presented to you in standard out when running `terraform plan`. This is the earliest phase in the dev workflow that you can rely on for your test assertions.

1. Learn to read the Terraform Plan

    You'll want to learn how to read a Terraform Plan. This will be the most efficient piece of information to use in discovering most of the infrastructure that your CIT plans to deploy before actual deployment. Terraform uses all module properties (i.e. input variables, output variables, provider blocks, resource blocks, other modules and more) present in your CIT in order to build a [Terraform Dependency Graph](https://www.terraform.io/docs/internals/graph.html) at plan time. This dependency graph is then represented as a list of resource address nodes that make up the Terraform plan visible in standard out. The state of that plan is what gets executed when running `terraform apply`.

2. Plan assertions to make about your CIT

    The resource addresses in your Terraform Plan have varying levels of nested information. Some of the values located at each resource address can be seen at plan time and some are so dynamic that they are not discoverable until the `terraform apply` command has finished executing. A good rule of thumb is values that are visible at plan time are unit testable, values not visible require integration testing.

    > **TIP:** Test as much as you can here because integration tests require spinning up and tearing down actual infrastructure beyond a state file.

    * Run `terraform plan` and look over the Terraform Plan that is presented so that you can decide on which assertions you'd like to make. It helps to consider each of the common properties that make up modules and their possible impact on the resource addresses that make up the plan.

        Here are a few examples of assertions we decided to make for tests within our az-hello-world CIT:

        | Terraform Plan Resource Address | Module Property Type | Planned Assertion  |
        |--------|-----------|-----------|-----------|
        | `module.app_service.azurerm_app_service.appsvc[0]` | module | Assert the presence of docker image in the configuration of the app service module. |
        | `module.service_plan.azurerm_app_service_plan.svcplan` | module | Assert that the service plan module for the az-hello-world CIT is configured for the least expensive S1 tier.   |
        | `azurerm_resource_group.main` | resource | Assert the resource group contains the datacenter used for test environments. |

### **Step 3:** Decide on which properties of your Terraform State are testable (Integration Tests)


### **Step 4:** Decide on a Go Testing Framework

### **Step 5:** Decide on a Terraform Testing Framework

Terratest vs kitchen-terraform.

### **Step 6:** Write Unit Tests

> **NOTE**: This example relies on the testing harness.

### **Step 7:** Run Unit Tests

### **Step 8:** Write Integration Tests

### **Step 9:** Run Integration Tests
