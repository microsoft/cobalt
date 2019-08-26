# Getting Started - Application Developer

### Overview
This section provide Cobalt technical operators with a general use case Azure DevOps pipeline. Operators can import this yaml based template when creating their pipeline in the Azure DevOPS portal.

### Fork the Repository

Fork the cobalt repository that has been created. For more details on creating the initial repository, please review [Getting Started](GETTING_STARTED_ADD_PAT_OWNER.md)

Fork the repository in either github or Azure DevOps

![image](https://user-images.githubusercontent.com/41071421/63653594-87146b80-c734-11e9-9282-ab9e8f874b83.png)


### Add Branching Strategy 

Add the branching strategy on the newly created fork to ensure the branches are protected. Branch Strategy can be added in Github or Azure DevOps Repo section directly

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

### Choose an existing project

If a project has not been created within an organization, please refer to [Getting Started](GETTING_STARTED_ADD_PAT_OWNER.md) on directions to create a project. 

![Select a Project](https://user-images.githubusercontent.com/41071421/63275190-af005c80-c266-11e9-9241-118f527551f4.png)

### Create a New Pipeline 

#### Select Pipelines on the left 

![Select Pipeline](https://user-images.githubusercontent.com/41071421/63275297-ea029000-c266-11e9-9288-33e34ee2e033.png)

#### Create new Pipeline 

![Create New Pipeline](https://user-images.githubusercontent.com/41071421/63275363-08688b80-c267-11e9-9fba-3022b3ac94a2.png)

#### Select Github as the source

![Choose Github](https://user-images.githubusercontent.com/41071421/63277498-102a2f00-c26b-11e9-87e4-167af2fafed0.png)

#### Choose the forked project

![Select the Forked Repo](https://user-images.githubusercontent.com/41071421/63281118-a95c4400-c271-11e9-9265-046eb2b2c804.png)

#### Configure the Pipeline and point the build definition to the repository's target yaml pipeline location

![Configure Pipeline](https://user-images.githubusercontent.com/41071421/63281246-e4f70e00-c271-11e9-861e-2c927a3e609b.png)

#### Add in the relative path to the target YAML pipeline location 

> Note: The dropdown to select the YAML file path may not auto populate so a copy and paste of the relative path from the repository may be required. 

![Select YAML Path](https://user-images.githubusercontent.com/41071421/63281630-be85a280-c272-11e9-9ff9-6e9a6ba73b82.png)

### Review your Pipeline and Run

![Review Pipeline](https://user-images.githubusercontent.com/41071421/63282088-af532480-c273-11e9-8e35-e7c425f2aee3.png)

Modify any changes as needed in the YAML and hit "Run". This is needed to initially save the YAML template. 

> Note: Build may initially fail until we finish the other steps. 

1. Go to the Pipeline that was created and hit "Edit"

![Edit Pipeline](https://user-images.githubusercontent.com/41071421/63284395-18896680-c279-11e9-95b7-bfad4d2d6a34.png)

2. Setup the variables needed by clicking "Triggers"

![Triggers](https://user-images.githubusercontent.com/41071421/63284806-022fda80-c27a-11e9-8e23-494314c63651.png)

3. Setup and link the variable groups 

Select the Variables groups and hit "Link variable group"
![Variable Groups](https://user-images.githubusercontent.com/41071421/63284674-aebd8c80-c279-11e9-802a-c4d20b4835ea.png)

Link the variable groups for DevInt, QA and Infrastructure one by one 

![Link Variable Groups](https://user-images.githubusercontent.com/41071421/63285023-74a0ba80-c27a-11e9-936c-be93bc8c1048.png)

4. Save Variables 

Drop down into the options for "Save & queue" and select "Save" and hit "Save" to save this build pipeline.

![Save Build](https://user-images.githubusercontent.com/41071421/63285205-e11bb980-c27a-11e9-8f3d-02a407f67075.png)

Hit "Queue" and then "Run" to start the build 

> Note: a specific commit can be picked from the selected branch, if nothing is added to the commit text box, it will default to the latest commit. 

![Start Build](https://user-images.githubusercontent.com/41071421/63285392-3b1c7f00-c27b-11e9-9bcb-92af0cd8789e.png)

The build will run through the stages and upon select a stage, more details will be presented on what the build is doing

![Stages for Build](https://user-images.githubusercontent.com/41071421/63285564-9fd7d980-c27b-11e9-8a9f-7835f6244339.png)

![Build Details](https://user-images.githubusercontent.com/41071421/63285648-d57cc280-c27b-11e9-916f-901185b2d97f.png)

Upon a successful build, all jobs will be marked off in green and shown as completed

![Successful Build](https://user-images.githubusercontent.com/41071421/63285815-399f8680-c27c-11e9-85c3-babffd75282b.png)

> Note: you may need to enable the experimental feature to allow multi-stage build pipelines if your view does not show the stages of the build pipeline. Directions for enabling preview features are available [here](https://docs.microsoft.com/en-us/azure/devops/project/navigation/preview-features?view=azure-devops).