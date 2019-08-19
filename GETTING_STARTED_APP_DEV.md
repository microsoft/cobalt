# Getting Started - Application Developer

### Overview
This section provide Cobalt technical operators with a general use case Azure DevOps pipeline. Operators can import this yaml based template when creating their pipeline in the Azure DevOPS portal.

### Fork the Repository

Fork the cobalt repository that has been created


### Add Branching Strategy 

Add the branching strategy on the newly created fork to ensure the branches are protected. 

#### Git: Master Branch Policies for IAC Repo

We strongly recommend adding branch policies to help protect the master branch and configure mandatory validation builds to avoid simultaneous builds when merging into master.

![image](https://user-images.githubusercontent.com/7635865/60196805-97c36680-9803-11e9-9fd0-7bedc34fc9ad.png)

Here's some more [guidance](https://docs.microsoft.com/en-us/azure/devops/pipelines/repos/github?view=azure-devops&tabs=yaml#protecting-branches) on leveraging Azure DevOPS build validation checks with protected branch's.

#### Recommended Branch Policies

- ✅ Do - Require pull request reviews before merging.
- ✅ Do - Prevent force pushing e.g. to prevent rewriting the commit history.
- ✅ Do - Require completion of Production stage release in Azure DevOPS before merging.
- ✅ Do - Prevent parallel releases into QA, staging and production environments.
- ✅ Do - Require status checks to pass before merging changes into the protected branch.

### Keep Advocated Patterns Needed

### Choose an existing project 

### Create a New Pipeline 

### Link Variable Groups 

### Run the Build
