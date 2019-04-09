# Contributing

Some general guidance around the process and steps to follow when contributing to this repository.

Clone the repo, and create a new feature branch on your local machine. Please name your feature branches by [convention](https://docs.microsoft.com/en-us/azure/devops/repos/git/git-branching-guidance?view=vsts#name-your-feature-branches-by-convention)(i.e. `$USER/bugfix/description`, `$USER/features/feature-area/feature-name`).

Make sure the tests pass both locally and through the CI build pipeline.

Push your branch to `origin` and submit a new pull request.

You should expect code reviewers to comment on pull requests within one business day. We may suggest some changes or improvements or alternatives.

Following an approval, the pull request submitter is responsible for squashing their commit messages completing their pr and deleting the branch.

Some things that will increase the chance that your pull request is accepted:

* Review our code review [guidance](https://github.com/Microsoft/code-with-engineering-playbook/blob/master/Engineering/CodeReviews.md).
* Follow our [engineering playbook](https://github.com/Microsoft/code-with-engineering-playbook#the-basics) and the [style guide][style] for this project.
* Include [unit tests](https://github.com/Microsoft/code-with-engineering-playbook/blob/master/Engineering/UnitTesting.md) and [end-to-end integration tests](https://martinfowler.com/bliki/IntegrationTest.html).
* Write a [good commit message](http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html).
* Pull request changes should meet the minimum code coverage threshold.