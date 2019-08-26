- [Cobalt](#cobalt)
- [Getting Started](#getting-started)
- [Relationship to Bedrock](#relationship-to-bedrock)
- [Community](#community)
- [Contributing](#contributing)

# Cobalt

[![Build Status](https://dev.azure.com/csedallascrew/project-cobalt/_apis/build/status/Microsoft.cobalt?branchName=master)](https://dev.azure.com/csedallascrew/project-cobalt/_build/latest?definitionId=2&branchName=master)
[![Go Report Card](https://goreportcard.com/badge/github.com/microsoft/cobalt)](https://goreportcard.com/report/github.com/microsoft/cobalt)

This project combines and shares best practices for building production ready [cloud native](https://www.cncf.io/) managed service solutions. Cobalt's infrastructure turn-key starter [templates](./infra/README.md) are based on real world engagements with enterprise customers.

Cobalt puts a focus on infrastructure scalability, security, automated testing and deployment repeatability and most importantly, developer experience. The Project's intended audience is for developers. Feedback and suggestions are encouraged through issue requests. We welcome contributions across any one of the major cloud providers.

Cobalt is a joint collaboration with project [Bedrock](https://github.com/Microsoft/bedrock).


![image](https://user-images.githubusercontent.com/7635865/60480300-be8ffb80-9c4e-11e9-819a-221cea2cb93b.png)

# Getting Started

The steps for getting started depends on your high level goals. Select the correct set of instructions based on your overall use case for Cobalt.

- [Getting Started - Cobalt Developer](./docs/GETTING_STARTED_COBALT_DEV.md): Start here if you want to contribute to the Cobalt repository to create new advocated pattern templates or pipelines.
- [Getting Started - Advocated Pattern Owner](./docs/GETTING_STARTED_ADD_PAT_OWNER.md): Start here if you want to maintain advocated pattern templates from Cobalt templates within your organization. Typically this will be the first step in leveraging Cobalt at your organization.
- [Getting Started - Application Developer](./docs/GETTING_STARTED_APP_DEV.md): Start here if your organization already uses Cobalt and you want to deploy an advocated pattern to host your application.




# Relationship to Bedrock

Cobalt hosts reusable Terraform modules to scaffold managed container services like [ACI](https://docs.microsoft.com/en-us/azure/container-instances/) and [Application Services](https://docs.microsoft.com/en-us/azure/app-service/) as a couple of examples. Bedrock targets Kubernetes-based container orchestration workloads while following a [GitOps](https://medium.com/@timfpark/highly-effective-kubernetes-deployments-with-gitops-c7a0354f1446) devops flow. Cobalt templates reference Terraform modules like virtual networks, traffic manager, etc.


# Community

[Please join us on Slack](https://publicslack.com/slacks/https-bedrockco-slack-com/invites/new) for discussion and/or questions.

# Contributing

We do not claim to have all the answers and would greatly appreciate your ideas and pull requests.

This project welcomes contributions and suggestions. Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.microsoft.com.

When you submit a pull request, a CLA-bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., label, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

For project level questions, please contact [Erik Schlegel](mailto:erisch@microsoft.com) or [James Nance](mailto:james.nance@microsoft.com).
