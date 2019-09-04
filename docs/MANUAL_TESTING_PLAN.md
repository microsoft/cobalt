# Manual Testing Plan

The purpose of the document is to highlight the steps that will be taken in order to run multiple deployments simultaenously within a single pipeline. This will jump start testing cycles needed to find shortcomings in for Cobalt deployments.

## Setup

1. Provision a VM in Azure.
1. Agree on a shared Azure DevOps (ADO) organization and project.
1. SSH into VM and download build agent.
1. Create a PAT from ADO and use it to configure the build agent
1. Configure agent pools in ADO to recognize build agent.
1. Test deployment pipeline with new VM
1. Repeat above steps for 3 more VMs.

## Testing Scenarios

Some testing scenarios may need to be discovered along the way. The initial test scenario will be to test parallel deployments.

> NOTE: Naming collisions are a known scenario that we must find a work around for. This scenario may be a blocker on all other testing scenarios.

### Scenario 1 - Parallel Deployments

#### Description

In an enterprise scenario, it's expected that a team will be deploying templates in parallel. Test parallel deployments and document any shortcomings along the way.

### Scenario 1 - Naming Collision Workaround

#### Description

Naming collisions are a known problem in Cobalt template deployments. Investigate a workaround that will allow manual testing to move forward. For example, az-hello-world does not enforce a unique name for app service fqdns during cicd pipeline deployments.
