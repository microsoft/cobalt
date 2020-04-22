- [About the Repository](#about-the-repository)
  - [Infrastructure as Code](#infrastructure-as-code)
  - [Continuous Integration / Deployment + Testing](#continuous-integration--deployment--testing)
    - [Azure DevOps CI Flow](#azure-devops-ci-flow)
- [Deploying your first template](#deploying-your-first-template)

# About the Repository

## Infrastructure as Code

Cobalt infrastructure templates are written in Terraform and can be found in the templates [folder](infra/templates). Each subfolder represents a unique deployment schema and is packaged with a set of Terraform scripts, overview and setup instructions and automated unit & integration tests.

Each template makes use of Terraform [modules](https://www.terraform.io/docs/modules/index.html) across both Bedrock and [Cobalt](infra/modules). Cobalt's module registry is categorized by cloud provider then resource type. Each modules represents an abstraction for the set of related cloud infrastructure objects that the module will manage.

```bash
$ tree infra
├───modules
│   └───providers
│       ├───azure
│       │   ├───api-mgmt
│       │   ├───app-gateway
│       │   ├───provider
│       │   ├───service-plan
│       │   ├───tm-endpoint-ip
│       │   ├───tm-profile
│       │   └───vnet
│       └───common
└───templates
    ├───az-hello-world
    │   └───test
    │       └───integration
    └───backend-state-setup
```

## Continuous Integration / Deployment + Testing

Cobalt Continuous Integration pipeline definitions are available in the `./devops/provider` folder. As of today, Cobalt provides a git devops workflow [definition](devops/providers/azure-devops/templates/infrastructure/azure-pipelines.yml) for Azure DevOps. We welcome pipelines from other providers like Jenkins.

### Azure DevOps CI Flow

![image](./design-reference/devops/providers/azure/cobalt-devops-ci.gif)

This pipeline is configured to trigger new builds for each new PR.

1. Deployment credential secrets such as service principal and terraform remote state storage accounts are sourced in azure keyvault.
2. The pipeline downloads secrets from keyvault and used to resolve terraform template variables.
3. The test harness image will be re-built. This includes copying any changes to Terraform scripts and the associated Terraform tests.
4. The test harness container will be run. It will perform the following stages.
    * Run a lint check on all golang test files and terraform templates.
    * Executes all golang unit tests.
    * Generate and validate the terraform plan.
    * Apply the terraform template resource updates to the development integration deployment environment.
    * Run end-to-end integration tests.
    * Tear down deployed resources.
5. Update the build and PR status.
6. Begin code review once the PR status is green.

# Deploying your first template

The easiest way to try Cobalt is to start with our [hello-world](https://github.com/Microsoft/cobalt/tree/master/infra/templates/az-hello-world) template.

Setting up a cobalt deployment comprises of 5 general steps.

1. You can follow these [instructions](../devops/providers/azure-devops/README.md) to create an cloud-based CI pipeline definition.
2. Our cloud deployment templates provide an configurable default setup intended for a t-shirt sized environment scenario. Pick the template folder most relevant to your use-case as a starting point. Each template folder is shipped with setup instructions.
3. It's important to implement quality assurance that validates E2E functional assertions against your infrastructure resources. Each template comes pre-packaged with some basic integration and unit tests. We encourage you to define integration tests in the `test/integration` folder of your template that's specific to your use-case.
4. Follow these [instructions](../test-harness/README.md) to setup your local environment. Make sure that the repository lives in a directory that does not live within `$GOPATH`.
5. Create a new local git branch and commit your changes. Run the test harness on your localhost via `./test-harness/local-run.sh`.

