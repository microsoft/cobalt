# Bootstrap for Cobalt IaC Pipelines on Azure DevOps

## Overview 
This provides a starting point for anyone interested in having an Azure DevOps
Project that will 'run' a target Cobalt template whenever that template changes.

### An example
Imagine that you are building a new set of web applications which are destined
to run on Azure. Those applications are going to use a few runtime resources, and you've
wisely decided to use a Cobalt template to satisfy and centralize your Infrastructure as Code ("IaC") 
needs across all of those applications. 

To get started, you want a central Git repository to store your IaC in, 
and following [solid engineering fundamentals](https://github.com/microsoft/code-with-engineering-playbook/tree/master/continuous-integration#continuous-integration),
you've decided to wrap CI/CD, and staged deployments around your IaC to help
protect the quality of your infrastructure changes.

This bootstrap (itself a Cobalt template) can be used to quickly, safely, and easily create 
the ADO resources (a Project, Git Repository, Build Definitions, Variable Groups, 
Service Connections, etc) that you'll need in that example.

### Terminology
Given that we're using a Cobalt template to create resources that will then operate other
Cobalt templates, discussing matters can become a bit confusing. To help with that, and 
to get specific about a few other terms we'll use, let's define a few terms and then use
them consistently, within this document and this bootstrap template itself.

|Term|Meaning|
|----|----|
|ADO|Azure DevOps, AKA "AzDO," elsewhere.|
|Application(s)|The application that will rely on the resources managed by the Infrastructure Template.|
|Bootstrap Template|This Cobalt template, as described in the example, above|
|IaC|Infrastructure as Code|
|Infrastructure Template|Whichever Cobalt template that will manage the Application(s) runtime resources. _By default, the Bootstrap Template points to the 'Hello World' example template in the official Cobalt GitHub repository._|
|Project|The ADO Project that the Bootstrap Template manage.|
|Build Definition|An ADO Build Definition that runs a pipeline. This Build Definition is managed by the Bootstrap Template.|

### Resources created & managed by this Bootstrap Template
The Bootstrap will:
- Create a new Azure DevOp Project.
- Create a set of Variables Groups in that Project.
- Create a new (empty) Git Repository in that Project.
- Create a new Build Definition in the Project.
- Create a new Service Connection from ADO to an Azure Subscription.

## Running the Bootstrap Template

### Set-up

## Temporary
That pipeline is defined by a YAML file expected to be found in the Infrastructure Template. The pipeline runs under 

## Todos
- [ ] describe all `variables` and `outputs`
- [ ] provide some in-line doc for the `.tf`
- [ ] write step-by-step guide
- [ ] audit/fix the variable groups that are being created