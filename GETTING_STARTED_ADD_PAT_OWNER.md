# Getting Started - Advocated Pattern Owner

## Prerequisites

  * An Azure Subscription
  * Azure Devops Organization
  * Permissions to your Organization's Azure Devops account
  * Azure cli

### Cobalt Enterprise Integration

1. Initialize Azure Repo Subscription with Cobalt

    * Create a new project
        * Sign-in to Azure DevOps (https://azure.microsoft.com/en-us/services/devops/)
        * Select New project and create a name. (ex. Cobalt-Hello-World-Contoso)
            * NOTE: If you already have a Cobalt template in mind, it may be a good idea to express that in the name.
        * Select Create
            * ![image](.Create_new_project.png)

    * Create new repository by fetching source code from Cobalt's master project
        * Select Repos tab within side-navigation menu
        * Select 'Import a repository' from the Repos tab sub-menu
        * Enter the Cobalt Clone URL (https://github.com/microsoft/cobalt.git) and select Import
            * ![image](.Import-succesfull-image.png)

    * Initialize new Azure Devops pipeline (devops/providers/azure-devops/templates/azure-pipelines.yml)
        * Select Pipelines tab within side-navigation menu
        * Select New pipeline and choose 'Azure Repos Git [YAML]'
        * Select newly created repository from dropdown menu
        * Import YAML by selecting 'Existing Azure Pipelines YAML file'
            * Enter the path to the devops yaml file that lives within your newly created repo. (i.e. devops/providers/azure-devops/templates/azure-pipelines.yml)
            * ![image](.Select-YAML-file.png)
        * Review devops pipeline YAML and only keep templates relevant to your enterprise patterns.
            * Remove jobName configurations not relevant to your enterprise patterns.
                ```yaml
                configurationMatrix:
                - jobName: az_service_single_region
                terraformTemplatePath: 'infra/templates/az-service-single-region'
                terraformWorkspacePrefix: 'sr'
                environmentsToTeardownAfterRelease:
                - 'devint'
                ```
            * NOTE: If new to Cobalt, we recommend keeping the az_hello_world template as a starter template. This step can also be completed later as a code commit to your repo.
        * Save and run
            * NOTE: Azure Devops forces a run so expect this to fail. Future steps will solve this problem.

2. Provision Azure resources needed for Azure Devops pipeline

    * Create a Cobalt admin service-principal/service-endpoint for Cobalt deployments
        * Sign-in to your organization's Azure account. (https://portal.azure.com)
        * Filter for Azure Active Directory and navigate to it's menu
        * Select App registrations from the menu blade
        * Click [Add/+] New registration then enter a name for the application (ex. cobalt-hw-admin-sp)
        * Choose single tenant as a supported account type to keep things simple.
        * Click Register

    * Configure the newly created registered app as a Service Principal
        * From the app's service blade, select the Certificates & Secrets tab
        * Click [Add/+] New from within Client secrets menu then enter a description (ex. rbac)
        * Click Add
            * NOTE: Take note of the generated client secret (only displayed once).
        * From the app's service blad, select Overview. Take note of the Application (client) ID for the next step.

    * Grant newly created Service Principal a Contributor role to your preferred enterprise subscription
        * Filter for subscriptions and navigate to the subscriptions list
        * Either choose a subscription or create a new one
        * Select your chosen subscription then select Access control (IAM) tab from the menu blade.
        * Click [+/Add] and select Add role assignment
            * From the sub-menu, select 'Contributor' from the drop down role and search for newly created Service Principal (i.e. cobalt-hw-admin-sp)
            * Click Save
            * ![image](.role-assignment-menu.png)

3. Configure Azure Devops pipeline
    * Fill in env vars for three variables groups (QA, DevInt, Global)
        * Env var for proxy will needed to be added
        * Env var for base acr image will needed to be added
        * All Env vars will eventually be migrated into ‘global group’
    * Create and build release steps
        * All build and release steps live in a yaml file.
    * Link variable groups
        * Navigate to build and release definitions
        * Click Variable groups
        * Select ‘Link Variable Groups’
    * Decide on agent pool to use for a build agent
        * Once agent pool is decided, reference agent pool in build and release steps
    * Set branch policy
        * Navigate to Branches ---> ellipses ---> Branch policies ---> require minimum # of reviewers [allow users]---> add build policy [ Automatic; Required; Build expires: Never; Display_Name: Cobalt_CICD ]

3. Clone newly created azure devops repo from your organization.
    * Visit your newly cloned repo and clone down the repo. (![image](.GitHub-Clone-Button.gif))
        ```bash
        $ git clone <insert-git-repo-url>
        ```

4. Keep the templates relevant to your enterprise patterns.
    * Open the project from your favorite IDE and navigate to infrastructure templates "./infra/templates."
    * Cherry pick template directories to be deleted and manually delete each one at a time.
    * Commit the newly pruned project to your newly forked repo.
        ```bash
        $ git commit -m "Removed unrelated templates." && git push
        ```
    NOTE: Do not delete 'backend-state-setup' template! We also recommended keeping the 'az-hello-world' template as a starter template.