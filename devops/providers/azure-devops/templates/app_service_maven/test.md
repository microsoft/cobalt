- ### Variable group naming conventions
	    Variable groups are named in a way that allows the pipeline to infer rather or not the group belongs to a specific environment within the release stage. Variable group naming conventions should be respected. They are hardcoded and parameterized in the following `yaml` files and are required. More details about the values of these variable groups are described in the [app usage](./examples/service_usage.md) example.
	    | Variable Group | YAML FILE |
	    | ---      | ---         |
	    |  `Azure - Common` | Service yaml |
	    |  `Azure - Common` | deploy-stages.yml |
	    |  `Azure Target Env - ${{ environment }}` | deploy-stages.yml |
	    |  `Azure Target Env Secrets - ${{ environment }}` | deploy-stages.yml |
	    |  `Azure Service Release - ${{ parameters.serviceName }}` | deploy-stages.yml |
	- ### Cloud provider and Environment boundaries
	    The **Shared Maven Service Pipeline** currently accomodates a multi-cloud **Maven Service** deployment. However, current implementation is Azure bound. Azure bound means that if you have a multi-cloud Maven Service, this pipeline only has an execution workflow targeting Azure infrastructure. The service contracts for other cloud providers are in place but have not been implemented. In short, deployments to a cloud provider are bound by their `yaml` pipeline configuration, the variable groups that belong to them and whether or not the Maven Service solution includes that cloud provider's implementation.
	    When adding a new environment for the release stage, satisfy the `${{ environment }}` parameter in the below variable groups. If implementations details have been flushed out for other cloud providers, the `${{ provider.name }}` parameters can be used.
	    | Variable Group |
	    | ---      |
	    |  `${{ provider.name }} Target Env - ${{ environment }}` |
	    |  `${{ provider.name }} Target Env Secrets - ${{ environment }}` |
    |  `${{ provider.name }} Service Release - ${{ parameters.serviceName }}` |