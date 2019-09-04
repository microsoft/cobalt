# Manual Testing Plan

The purpose of the document is to highlight the steps that will be taken in order to jump start the testing cycles needed to find shortcomings with Cobalt deployments.

## Setup

- Validate Azure DevOps (ADO) Scenario
    - If ADO scenario requires multiple build agents, follow the below steps:
        1. Provision a VM in Azure.
        1. Agree on a shared Azure DevOps (ADO) organization and project.
        1. SSH into VM and download build agent.
        1. Create a PAT from ADO and use it to configure the build agent
        1. Configure agent pools in ADO to recognize build agent.
        1. Test deployment pipeline with new VM using Fork-and-Go
        1. Repeat above steps for 3 more VMs.
        1. Begin documenting any deployment issues following the GETTING_STARTED_ADD_PAT_OWNER.md instructions. Use the below testing scenarios as a reference.
        1. Begin documenting any deployment issues following the GETTING_STARTED_APP_DEV_CLI.md  instructions. Use the below testing scenarios as a reference.
    * If AZDO scenario does not require multiple build agents, follow the below steps:
        1. Document any deployment issues following the GETTING_STARTED_ADD_PAT_OWNER.md instructions. Use the below testing scenarios as a reference.
        1. Document any deployment issues following the GETTING_STARTED_APP_DEV_CLI.md instructions. Use the below testing scenarios as a reference.

## Testing Scenarios

Some testing scenarios may need to be discovered along the way. The initial test scenario will be to test parallel deployments.

> NOTE: Naming collisions are a known scenario that we must find a work around for. This scenario may be a blocker on all other testing scenarios.

### Scenario 1 - Parallel Deployments

#### Description

In an enterprise scenario, it's expected that a team will be deploying templates in parallel. Test parallel deployments and document any shortcomings along the way.

### Scenario 2 - Naming Collision Workaround

#### Description

Naming collisions are a known problem in Cobalt template deployments. Investigate a workaround that will allow manual testing to move forward as a temporary fix. For example, az-hello-world does not enforce a unique name for app service fqdns during cicd pipeline deployments.

### Scenario 3 - Off-script testing

#### Description

There is a tendency to overlook documented steps when following general instructions. Find those common pit-falls and call them out in the documentaiton.
