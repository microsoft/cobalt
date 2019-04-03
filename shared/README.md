
# Resource deployment

## Requirements

- Azure Subscription
- [Terraform](https://www.terraform.io/downloads.html)

Fill the values required below in backend.tfvars to initialize Azure backend for Terraform, using the information [below](###Configure-Terraform-to-Store-State-Data-in-Azure)

- Storage Account Name
- Storage Account Access Key
- Storage Account Container Name
- Key Name to store for Terraform State for Test Environment


## Resources

The following resources will be deployed:
- Azure Resource Group
- Azure KeyVault 

## Deployment

### Authenticate using your Azure Principal or an Azure account with privileges to deploy resource groups.

``` bash
$ az login
```

### Configure Terraform to Store State Data in Azure

Terraform records the information about what is created in a [Terraform state file](https://www.terraform.io/docs/state/) after it finishes applying.  By default, Terraform will create a file named `terraform.tfstate` in the directory where Terraform is applied.  Terraform needs this information so that it can be loaded when we need to know the state of the cluster for future modifications.

In production scenarios, storing the state file on a local file system is not desired because typically you want to share the state between operators of the system.  Instead, we configure Terraform to store state remotely, and in Cobalt we use Azure Blob Store for this storage.  This is defined using a `backend` block.  The basic block looks like:

```bash
terraform {
   backend “azure” {
   }
}
```

In order to setup an Azure backend, one needs an Azure Storage account.  If one must be provisioned, use [this](https://docs.microsoft.com/en-us/cli/azure/storage/account?view=azure-cli-latest#az-storage-account-create) link to provision, where `name` is the name of the storage account to store the Terraform state, `location` is the Azure region the storage account should be created in, and `resource group` is the name of the resource group to create the storage account in.  

If there is already a pre-existing storage account, then retrieve the equivalent information for the existing account.

Once the storage account details are known, we need to fetch the storage account key so we can configure Terraform with it:

```bash
>  az storage account keys list --account-name <storage account name>
```

Once the storage account is created, one needs to create a container needed to store the Terraform state using [this](https://docs.microsoft.com/en-us/cli/azure/storage/container?view=azure-cli-latest#az-storage-container-create) link. Use the above storage account details required to create the container. 

Once the container is created, update `backend.tfvars` file in your cluster environment directory with these values. 

### Execute following commands to setup using the Azure backend:

``` bash
$ cd ./shared
$ terraform init -backend-config=./backend.tfvars
```

### Execute the following commands to deploy resources:

``` bash
$ cd ./shared
$ terraform apply
```

To stop the command line from prompting questions use a .env file with the following environmental variables:

```
export TF_VAR_location=eastus
export TF_VAR_company=myCompany
```

After saving the file set environment using:

``` bash
. .env
```

Alternatively, use the shared.tfvars file to set parameter values as shown below:

``` 
location="eastus"
company="myCompany"
```
