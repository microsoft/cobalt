# Getting Started - Cobalt Developer

The easiest way to try Cobalt is to start with our [hello-world](https://github.com/Microsoft/cobalt/tree/master/infra/templates/az-hello-world) template.

Setting up a cobalt deployment comprises of 5 general steps.

1. You can follow these [instructions](devops/providers/azure-devops/README.md) to create an cloud-based CI pipeline definition.
2. Our cloud deployment templates provide an configurable default setup intended for a t-shirt sized environment scenario. Pick the template folder most relevant to your use-case as a starting point. Each template folder is shipped with setup instructions.
3. It's important to implement quality assurance that validates E2E functional assertions against your infrastructure resources. Each template comes pre-packaged with some basic integration and unit tests. We encourage you to define integration tests in the `test/integration` folder of your template that's specific to your use-case.
4. Follow these [instructions](test-harness/README.md) to setup your local environment. Make sure that the repository lives in a directory that does not live within `$GOPATH`.
5. Create a new local git branch and commit your changes. Run the test harness on your localhost via `./test-harness/local-run.sh`.