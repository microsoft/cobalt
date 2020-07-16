# Azure Application Services

The `az-svc-data-integration-mlw` template is intended to be a reference for running a set of app services.


## Use-Case

This particular template creates an Azure environment with a small set of fully managed microservices.


## Scenarios this template should avoid

This template is an adequate solution where the service count is less than 10. For Azure customers interested with provisioning more than 10 services, we recommend using AKS. Reason being that with Kubernetes you can maximize cluster node CPU cores which helps minimize cloud resourcing costs.

## Technical Design
Template design [specifications](docs/design/README.md).

## Architecture
![Template Topology](docs/design/images/deployment-topology.jpg "Template Topology")


## Prerequisites

1. Azure Subscription
2. An available Service Principal with API Permissions granted with Admin Consent within Azure app registration. The required Azure Active Directory Graph app role is `Application.ReadWrite.OwnedBy`

![image](https://user-images.githubusercontent.com/7635865/71312782-d9b91800-23f4-11ea-80ee-cc646f1c74be.png)

3. Terraform and Go are locally installed
4. Azure Storage Account is [setup](https://docs.microsoft.com/en-us/azure/terraform/terraform-backend) to store Terraform state
5. Set up your Local environment variables by creating a `.env` file that contains the following information:

```
ARM_SUBSCRIPTION_ID="<az-service-principal-subscription-id>"
ARM_CLIENT_ID="<az-service-principal-client-id>"
ARM_CLIENT_SECRET="<az-service-principal-auth-secret>"
ARM_TENANT_ID="<az-service-principal-tenant>"
ARM_ACCESS_KEY="<remote-state-storage-account-primary-key>"
TF_VAR_remote_state_account="<tf-remote-state-storage-account-name>"
TF_VAR_remote_state_container="<tf-remote-state-storage-container-name>"
```

## Cost

Azure environment cost ballpark [estimate](https://azure.com/e/92b05a7cd1e646368ab74772e3122500). This is subject to change and is driven from the resource pricing tiers configured when the template is deployed. 

## Deployment Steps

1. Execute the following commands to set up your local environment variables:

*Note for Windows Users using WSL*: We recommend running dos2unix utility on the environment file via `dos2unix .env` prior to sourcing your environment variables to chop trailing newline and carriage return characters.

```bash
# these commands setup all the environment variables needed to run this template
DOT_ENV=<path to your .env file>
export $(cat $DOT_ENV | xargs)
```

2. Execute the following command to configure your local Azure CLI.

```bash
# This logs your local Azure CLI in using the configured service principal.
az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID
```

3. Navigate to the `terraform.tfvars` terraform file. Here's a sample of the terraform.tfvars file for this template.

```HCL
resource_group_location = "centralus"
prefix                  = "test-services"

# Targets that will be configured to also setup AuthN with Easy Auth
app_services = [
  {
    app_name = "tf-test-svc-1"
    image    = null
    app_settings = {
      "one_sweet_app_setting" = "brilliant"
    }
  },
  {
    app_name = "tf-test-svc-2"
    image    = null
    app_settings = {
      "another_sweet_svc_app_setting" = "ok"
    }
  }
]
```

4. Execute the following commands to set up your terraform workspace.

```bash
# This configures terraform to leverage a remote backend that will help you and your
# team keep consistent state
terraform init -backend-config "storage_account_name=${TF_VAR_remote_state_account}" -backend-config "container_name=${TF_VAR_remote_state_container}"

# This command configures terraform to use a workspace unique to you. This allows you to work
# without stepping over your teammate's deployments
TF_WORKSPACE="az-micro-svc-$USER"
terraform workspace new $TF_WORKSPACE || terraform workspace select $TF_WORKSPACE
```

5. Execute the following commands to orchestrate a deployment.

```bash
# See what terraform will try to deploy without actually deploying
terraform plan

# Execute a deployment
terraform apply
```

6. Optionally execute the following command to teardown your deployment and delete your resources.

```bash
# Destroy resources and tear down deployment. Only do this if you want to destroy your deployment.
terraform destroy
```

## Automated Testing

### Unit Testing 

Navigate to the template folder `infra/templates/az-svc-data-integration-mlw`. Unit tests can be run using the following command:

```
go test -v $(go list ./... | grep "unit")
```

### Integration Testing

Please confirm that you've completed the `terraform apply` step before running the integration tests as we're validating the active terraform workspace.

Integration tests can be run using the following command:

```
go test -v $(go list ./... | grep "integration")
```