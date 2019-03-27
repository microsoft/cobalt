<<<<<<< HEAD

# Setup

The artifacts used to deploy this project include bash scripts and Terraform templates.  The sections below provide guidance to deploy this project into your Azure environment.

> The setup instructions below assume the following requirements:
> - bash v4.0 (or newer)
>   - **NOTE FOR MAC!** The default version of bash installed on Mac is older than 4.0. Be sure to update bash using brew before executing the script. Instructions to update bash can be found [here](http://macappstore.org/bash/).
> - Terraform v0.11.13 (or newer)


## Setup the Azure Container Registry and Service Principals

1. Open a bash command prompt.
2. Navigate to the `./setup` folder.
3. Run `acr-sp-init.sh`.  For example, the command below will provdision an Azure Container Registry (ACR) in East US and configure the two service principals in Azure Active Directory; one with AcrPush permission and another with AcrPull permission scoped to the ACR.  The company name parameter ( `-c` ) is used to construct the name of the resource group, ACR, and service principals.

    ``` bash
    $ ./acr-sp-init.sh -c Cobalt -l eastus
    ```

    > Note: The script configures service principals in Azure AD and therefore requires elevated privileges.  As such, it is recommended that an interactive user with permissions to configure Azure AD run the script.
    
    
## Setup Shared / Core Infrastructure

### Requirements

- Azure Subscription User (with deployment rights)
- [Terraform](https://www.terraform.io/downloads.html)

### Resources

The following respources will be deployed
- Azure Resource Group

### Deployment

1. Authenticate using your Azure Principal or an Azure account with privileges to deploy resource groups.

``` bash
$ az login
```

2. Execute the following commands:

``` bash
$ cd ./shared
$ terraform init
$ terraform apply
```

### Environmental Variables 

To stop the command line from prompting questions use a .env file with the following environmental variables:

```
export TF_VAR_app_name=cblt
export TF_VAR_org=cse
export TF_VAR_env=dev
export TF_VAR_location=eastus
```

After saving the file set environment using:

``` bash
. .env
```

Alternative use the variable.tf files in the directories and add the default key on the file as shown on the example below:

``` json
variable "location" {
    type = "string"
    description = "The name of the target location"
    default = "eastus"
}
variable "env" {
    type = "string",
    description = "The short name of the target env (i.e. dev, staging, or prod)"
    defailt = "dev"
}
variable "org" {
    type = "string",
    description = "The short name of the organization"
    default = "cse"
}
variable "app_name" {
    type = "string",
    description = "The short name of the application"
    default = "cblt"
}

```

## Setup Application Infrastructure

> Coming soon!


# Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.microsoft.com.

When you submit a pull request, a CLA-bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., label, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.
=======

# Setup

The artifacts used to deploy this project include bash scripts and Terraform templates.  The sections below provide guidance to deploy this project into your Azure environment.

> The setup instructions below assume the following requirements:
> - bash v4.0 (or newer)
>   - **NOTE FOR MAC!** The default version of bash installed on Mac is older than 4.0. Be sure to update bash using brew before executing the script. Instructions to update bash can be found [here](http://macappstore.org/bash/).
> - Terraform v0.11.13 (or newer)


## Setup the Azure Container Registry and Service Principals

1. Open a bash command prompt.
2. Navigate to the `./setup` folder.
3. Run `acr-sp-init.sh`.  For example, the command below will provdision an Azure Container Registry (ACR) in East US and configure the two service principals in Azure Active Directory; one with AcrPush permission and another with AcrPull permission scoped to the ACR.  The company name parameter ( `-c` ) is used to construct the name of the resource group, ACR, and service principals.

    ``` bash
    $ ./acr-sp-init.sh -c Cobalt -l eastus
    ```

    > Note: The script configures service principals in Azure AD and therefore requires elevated privileges.  As such, it is recommended that an interactive user with permissions to configure Azure AD run the script.
    
    
## Setup Shared / Core Infrastructure

> Coming soon!

## Setup Application Infrastructure

> Coming soon!


# Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.microsoft.com.

When you submit a pull request, a CLA-bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., label, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.
>>>>>>> master
