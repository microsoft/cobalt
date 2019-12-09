# 4. Template Testing

## 4.1 Overview

As software developers, we seek out opportunities to improve and grow projects via code contributions. Code contributions, whether major or gradual, require changes that unfortunately bring with them a chance of unexpected behavior to occur. Fortunately, automated testing grants us a chance to gain more predictability and control over the changes that occur from our contributions. By running pre-existing automated tests every time new code changes are introduced, we can catch problems before they are deliverd into a production environment.

With that being said, the task of building automated tests for infrastructure can feel a bit different then the kinds of tests you are used to. For this project, let's further build on what you've learned so far by introducing the approach Cobalt has taken to infrastructure testing and how that will impact what you know about the Cobalt Developer Workflow. Happy testing! 😄

> *Have yet to create a Cobalt Infrastructure Template or CIT (/kɪt/) of your own? Design and create your first infrastructure template with Cobalt by completing our [Cobalt Templating From Scratch](./3_NEW_TEMPLATE.md) walkthrough.*

## 4.2 Goals and Objectives

🔲 Design and build automated tests for the az-function-hw CIT

🔲 Demonstrate how testing fits into the SDLC for writing *CIT*s

🔲 Demonstrate how to avoid regressions with robust unit and integration tests

🔲 Feel confident in moving forward to our next recommended section: *[Operationalizing CITs - A CICD Approach](./5_OPERATIONALIZE_TEMPLATE.md)*

## 4.3 Prerequisites

| Prereqs | Description |
|----------|--------------|
| [Quickstart Guide](./2_QUICK_START_GUIDE.md) | This should have served as your first Cobalt Infrastructure deployment. |
| [Cobalt Templating From Scratch](./3_NEW_TEMPLATE.md) | Completing this prequisite leaves you with a CIT that you can test in this walkthrough. |
| [Terraform Modules](https://www.terraform.io/docs/configuration/modules.html) | An introductory understanding of Terraform modules.|
| [Golang](https://golang.org/dl/) (1.12.5 +) | Our testing strategy depends on Golang. Install it and gain an introductory understanding. |
| [Go Modules](https://blog.golang.org/using-go-modules) | An introductory understanding of Golang's latest dependency management system. |
| [Go Test](https://golang.org/pkg/testing/) | An introductory understanding of Golang's native testing package. |
| [TerraTest](https://github.com/gruntwork-io/terratest) | An introductory understanding of TerraTest. |

## 4.4 Walkthrough - Testing a Cobalt Infrastructure Template (CIT)

If you are used to developing in Terraform, you'll realize that the Cobalt Developer Workflow is the way it is because CITs are primarily written in Terraform's HCL configuration language as are the modules that they are composed of. Executing this workflow so far has required you to use the Terraform cli. However, you might not have known that the Terraform cli is actually running commands against [Terraform Core](https://www.terraform.io/docs/extend/how-terraform-works.html#terraform-core), a statically compiled Golang binary. Therefore, in order to programmatically interact with Terraform to implement test automation, the most practical path is to use Golang.

Furthermore, you'll have to know where in an automated way it is that you can start making assertions about your CIT's deployment plans and the infrastructure that it will stand up. Keep your knowledge of the Cobatl Developer Workflow in mind as you complete the following steps provided for writing automated tests in Golang for your CIT.

> **NOTE:** This walkthrough only focuses on running automated tests locally. Our next walkthrough *[Operationalizing CITs - A CICD Approach](./5_OPERATIONALIZE_TEMPLATE.md)* will cover ways that these automated tests can be run on code commits and various deployment stages.

### **Step 1:** Prepare for Test Isolation

You'll want to make sure that your tests are using actual test values before programmatically running `terraform plan` in Golang. The values you provide should be non-production values so as to not affect end-user environments. In the Cobalt Develop Workflow, the opportunities to enforce test isolation first begin with setting up your local environment variables, and then running `terraform init` and `terraform workspace new <workspaceName>` from your CIT's directory.

> **NOTE:** Due to the beginning of the Cobalt Developer Workflow having a hard dependency on a remote back-end state file, both unit testing and integration testing will need these environment variables. Therefore, we highly recommend completing this step.

1. Prepare your environment variables for dev

    See step 3 of the [quick start guide](./2_QUICK_START_GUIDE.md) for guidance on how to setup your environment variables. Ensure that your .env file is using non-production values as you will be referencing these when writing your automated tests for the az-function-hw CIT in Golang. These values are specific to the provider your CIT is targeting. In this case, it's Azure. Here are a few examples:

    | Env Variables | Test Value | Description |
    |--------|----------|-----------|
    | `storage_account_name`  | Value from "TF_VAR_remote_state_account" | This value should be the storage account dedicated to the dev environment. The value lives within your .env file. |
    | `container_name`  | Value from "TF_VAR_remote_state_container" | This value will be the dedicated remote container that will hold multiple Terraform backend workspace state files. The value lives within your .env file. |

2. Locate the input variables from your CIT that further help you achieve test isolation then prepare values for them.

    > **NOTE:** Some CITs rely on a commons.tf file that resolves input names into unique names for cloud infrastructure resources like fqdns. The commons.tf file is an answer to the inherit naming constraints that come with some cloud resources. Therefore, some of the names you provide as inputs for your CIT will be further sanitized by the commons.tf file. Another feature of this file is that it improves work isolation.

    Here are all the input variables and values you'll use to help further prepare the az-function-hw CIT for test isolation in Golang:

    | Input Var Name | Test Value | Description |
    |--------|----------|-----------|
    | `workspace` | "az-func-hw-" + guid | Teams share cloud provider resources and accounts. A workspace name with a random guid may be your only solution to working in isolation from other devs on your team. |
    |  `name`  | "az-func-hw-unit-tst-" + guid | A prefix name for appending unique values to resources that require a unique name. Helpful for integration tests that create actual infrastructure.|
    | `resource_group_location`  | "eastus" | The geo-location of the Azure datacenters inside of which you want the resource group that will contain your dev infrastructure to live. |

### **Step 2:** Develop Your Terraform Plan Based Assertions (Unit Testing)

The previous step properly prepared you for test isolation. Now you can concern yourself with the business of test assertions. The best way to formulate test assertions about your CIT is to rely on what's visible in the Terraform Plan. Terraform Plans are presented to you in standard out when running `terraform plan`. This is the earliest phase in the dev workflow where you'll use Golang to run tests programmatically.

1. Learn to read the Terraform Plan

    You'll want to learn how to read a [Terraform Plan](https://www.terraform.io/docs/commands/plan.html). This will be the most efficient piece of information to use in discovering most of the infrastructure that your CIT plans to deploy before actual deployment. In short, Terraform uses all module properties (i.e. input variables, output variables, provider blocks, resource blocks, other modules and more) present in your CIT in order to build a [Dependency Graph](https://www.terraform.io/docs/internals/graph.html) at plan time. This dependency graph is then represented as a list of resource address nodes that make up the Terraform plan visible in standard out. The state of that plan is what gets executed when running `terraform apply`.

2. Inspect Terraform Plan to formulate test assertions about your CIT

    The resource addresses visible in your Terraform Plan have varying levels of nested information. Some of the values located at each resource address can be seen at plan time and some are not resolvable until the `terraform apply` command has finished executing.

    > **TIP:** A good rule of thumb is, "values visible at plan time are unit testable, values not visible require integration testing.". Make full use of your unit tests because integration tests require spinning up and tearing down real infrastructure and that takes time.

    * Run `terraform plan` and inspect the Terraform Plan to formulate test assertions. It helps to consider each of the common properties that make up modules and their possible impact on the resource addresses that make up the plan. Here are the test assertions we formulated your az-function-hw CIT's unit tests. Use the following:

        | Terraform Plan Resource Address | Module Property Type | Test Assertion  |
        |--------|-----------|-----------|
        | `module.function_app.azurerm_function_app.walkthrough` | module | Assert that the value "az-function-hw-walkthrough" is present in the azure function module's configuration. |
        | `module.service_plan.azurerm_app_service_plan.svcplan` | module | Assert that the service plan module is configured as a "FunctionApp" and that the Function App sku is "Dynamic". |

### **Step 3:** Develop Your Terraform Apply Based Assertions (Integration Tests)

In the previous step we stated, "Values visible at plan time are unit testable, values not visible require integration testing.". After completing the exercise of developing Terraform _Plan_ based assertions, it follows that we must also develop Terraform _Apply_ based assertions. These are test assertions about values that are not resolvable until the `terraform apply` command finishes deploying real infrastructure.

* Make unresolvable Terraform Plan values testable. - Visit [Terraform Outputs](https://www.terraform.io/docs/configuration/outputs.html) to learn more.

    You'll have to map unresolvable Terraform Plan values to CIT outputs. Outputs are simply return values for modules, therefore, your CIT can also have return values. These outputs are visible in standard out when the `terraform apply` command has finished executing. Reconfigure your CIT by taking unresolvable properties that you care about from your Terraform Plan and mapping them to outputs configured in your CIT. Here's an example of an integration test assertion we formulated for your az-function-hw CIT:

    | Unresolvable Terraform Plan Value  | Output Var Name | Planned Assertion |
    |--------|-----------|-----------|
    | `module.app_service.azure_function_url` | `azure_function_default_hostname` | Assert that the azure function module's app service url (A value that is mapped to the CIT's output.) returns a status of 200. |


### **Step 4:** Choose Testing Frameworks (Terraform and Golang)

It is our opinion that the job of the testing framework you ultimately choose should be based on how well it lends itself to executing on the assertions you developed in the previous steps. In our case, we chose [TerraTest](https://github.com/gruntwork-io/terratest) as our Terraform testing framework. A byproduct of using TerraTest is that we must also use Golang's native testing framework ([Go Test](https://golang.org/pkg/testing/)) because Terratest depends on it. Visit [How-terratest-compares-to-other-testing-tools](https://github.com/gruntwork-io/terratest#how-terratest-compares-to-other-testing-tools) to examine the trade-offs.

### **Step 5:** Write Unit Tests

When writing unit tests for Cobalt CITs, we suggest coding against our provided [test harness](./../test-harness/README.md). Our test harness minimizes the boiler plate code required to wire-up [TerraTest](https://github.com/gruntwork-io/terratest) and [Go Test](https://golang.org/pkg/testing/) for test automation.

The test harness implementation partially automates the command line execution of the Cobalt Developer Workflow (i.e. *create/choose/extend* a template/module ---> init ---> select workspace ---> plan ---> **test** ---> destroy). The test harness is packaged and is exposed in way that allows you to provide your custom testing context as inputs to the harness.

1. Navigate to the az-function-hw CIT directory (i.e. ./infra/templates/az-function-hw) and execute the following commands to wire up your new test repository:

    ```bash
    # Create a directory called "tests"
    mkdir -p ./tests
    # Navigate to the tests directory
    cd tests
    # Create a directory called "unit"
    mkdir -p ./unit
    # Navigate to the unit directory
    cd unit
    # Create a test file
    touch az_function_hw_test.go
    ```

1. Initialize the test file and it's test harness variables for dev isolation with the following go code snippet:

    The code snippet below initializes a Terratest object called *Options* with the values from an earlier step that we pre-selected for achieving test isolation. This *Options* object act as the first step for setting up the context needed to run unit tests within the test harness.

    > **NOTE:** Golang compiles to a static library, therefore, it's important that all types are defined ahead of time. With a little familiarity on how the [Golang interface](https://tour.golang.org/methods/14) type behaves, you'll understand how the below examples initialize variables to provide context to the testing harness hooks for running unit tests within the az-function-hw CIT.

    ```go
    package test

    import (
        "fmt"
        "os"
        "testing"

        "github.com/gruntwork-io/terratest/modules/random"
        "github.com/gruntwork-io/terratest/modules/terraform"
        "github.com/microsoft/cobalt/test-harness/infratests"
    )

    var workspace = fmt.Sprintf("az-func-hw-%s", random.UniqueId())
    var prefix = fmt.Sprintf("az-func-hw-unit-tst-%s", random.UniqueId())
    var datacenter = "eastus"

    var tfOptions = &terraform.Options{
        TerraformDir: "../../",
        Upgrade:      true,
        Vars: map[string]interface{}{
            "name":                    prefix,
            "resource_group_location": datacenter,
        },
        BackendConfig: map[string]interface{}{
            "storage_account_name": os.Getenv("TF_VAR_remote_state_account"),
            "container_name":       os.Getenv("TF_VAR_remote_state_container"),
        },
    }
    ```

2. Add your Terraform Plan based assertions to the test file using the following go code snippet:

    The code snippet below initializes a custom test harness object called *UnitTestFixture* with the values that will be later passed to Terratest and other logic needed for test automation. The *ResourceDescription* object is where you plug in your formulated test assertions as code. The test harness will run assertions for you by parsing the Terraform Plan as long as you provide the expected values and their respective data types.

    ```go
    func TestAzureSimple(t *testing.T) {
        testFixture := infratests.UnitTestFixture{
            GoTest:                t,
            TfOptions:             tfOptions,
            ExpectedResourceCount: 6,
            PlanAssertions:        nil,
            Workspace:             workspace,
            ExpectedResourceAttributeValues: infratests.ResourceDescription{
                "module.function_app.azurerm_function_app.walkthrough": map[string]interface{}{
                    "app_settings": map[string]interface{}{
                        "environment": "az-function-hw-walkthrough",
                    },
                },
                "module.service_plan.azurerm_app_service_plan.svcplan": map[string]interface{}{
                    "kind":     "FunctionApp",
                    "sku": []interface{}{
                        map[string]interface{}{"size": "Y1", "tier": "Dynamic"},
                    },
                },
            },
        }

        infratests.RunUnitTests(&testFixture)
    }
    ```

### **Step 6:** Run Unit Tests

Tests are run from the command line using Golang's testing framework Go Test.

* **RUN TESTS LOCALLY**

1. From your existing unit test directory, execute your tests by running the following go command:

    ```bash
    go test
    ```

### **Step 7:** Write Integration Tests

When running integration tests in Cobalt, we suggest coding against our provided [test harness](./../test-harness/README.md). Our test harness minimizes the boiler plate code required to wire-up [TerraTest](https://github.com/gruntwork-io/terratest) and [Go Test](https://golang.org/pkg/testing/) for test automation.

1. Run Terraform Apply against a dev workspace environment

    The test harness integration test automates the comparison of a CIT's resolved outputs against expected values that you provide in your tests. The integration test **does not** run `terraform apply` against your CIT to create infrastructure. This is a step you must do yourself in order for your CIT to have resolved outputs. These outputs are written to the CIT's workspace state.

    1. Setup Environment Variables for your dev workspace

    1. See step 3 of the [quick start guide](./2_QUICK_START_GUIDE.md) for guidance on how to setup your environment variables.

    1. Initialize the default Terraform Remote Workspace

    1. See step 4 of the [quick start guide](./2_QUICK_START_GUIDE.md) for guidance on how to initalize a Terraform remote workspace.

    1. From the az-function-hw directory, execute the following commands to run a template and execute a deployment.

        ```bash
        # Select your existing dev workspace
        terraform workspace select az-function-hw-$USER
        # Ensure that the current workspace is az-function-hw-$USER.
        terraform workspace show
        # See what terraform will try to deploy without actually deploying.
        terraform plan
        # Run Azure Function Hello World CIT to execute a deployment.
        terraform apply
        ```

2. Navigate to the az-function-hw tests directory (i.e. ./infra/templates/az-function-hw/tests) and execute the following commands to wire up your new integration test repository:

    ```bash
    # Create a directory called "integration"
    mkdir -p ./integration
    # Navigate to the integration directory
    cd integration
    # Create a test file
    touch az_function_hw_test.go
    ```

3. Initialize the test file and it's test harness variables for dev isolation with the following go code snippet:

    ```go
    package test

    import (
        "os"
        "strings"
        "testing"
        "time"

        httpClient "github.com/gruntwork-io/terratest/modules/http-helper"
        "github.com/gruntwork-io/terratest/modules/terraform"
        "github.com/microsoft/cobalt/test-harness/infratests"
    )

    var tfOptions = &terraform.Options{
        TerraformDir: "../../",
        Upgrade:      true,
        BackendConfig: map[string]interface{}{
            "storage_account_name": os.Getenv("TF_VAR_remote_state_account"),
            "container_name":       os.Getenv("TF_VAR_remote_state_container"),
        },
    }
    ```

4. Add your Terraform Apply based output assertions

    The code snippet below initializes a custom test harness object called *IntegrationTestFixture* with the context you provide for the Terratest framework. The *TfOutputAssertions* object is where you plug in your formulated test assertions as code. In this example, the test assertion is in the form of a function pointer that will make an http call when executed. The test harness will execute this function for you.

    ```go
    // Validates that the service responds with HTTP 200 status code. A retry strategy
    // is used because it may take some time for the application to finish standing up.
    func httpGetRespondsWith200(goTest *testing.T, output infratests.TerraformOutput) {
        hostname := output["azure_function_default_hostname"].(string)
        maxRetries := 20
        timeBetweenRetries := 2 * time.Second
        expectedResponse := "Hello App Service!"

        err := httpClient.HttpGetWithRetryWithCustomValidationE(
            goTest,
            hostname,
            maxRetries,
            timeBetweenRetries,
            func(status int, content string) bool {
                return status == 200 && strings.Contains(content, expectedResponse)
            },
        )
        if err != nil {
            goTest.Fatal(err)
        }
    }

    func TestAzureSimple(t *testing.T) {
        testFixture := infratests.IntegrationTestFixture{
            GoTest:                t,
            TfOptions:             tfOptions,
            ExpectedTfOutputCount: 1,
            TfOutputAssertions: []infratests.TerraformOutputValidation{
                httpGetRespondsWith200,
            },
        }
        infratests.RunIntegrationTests(&testFixture)
    }
    ```

### **Step 8:** Run Integration Tests

* **RUN TESTS LOCALLY**

1. Navigate back to the az-function-hw directory (i.e. ./infra/templates/az-function-hw) and run the following commands to execute your integration tests:

    > **NOTE:** Integration tests must be run from the CIT's main directory, **not the test sub-directory**. This allows the integration test to run against the proper workspace context.

    ```bash
    # Select your existing dev workspace
    terraform workspace select az-function-hw-$USER
    # Ensure that the current workspace is az-function-hw-$USER.
    terraform workspace show
    # Use Golang to execute your integration test
    go test ./tests/integration
    ```

## Conclusion

Completion of this walkthrough means that you have used the az-function-hw CIT to fully exercise the Cobalt Developer Workflow (i.e. create/choose a template ---> init ---> select workspace ---> plan ---> test ---> apply ---> test ---> destroy). Please continue to the recommended next step for guidance on operationalizing a CIT.

### **Recommended Next Step:** *[Operationalizing CITs - A CICD Approach](./5_OPERATIONALIZE_TEMPLATE.md)*