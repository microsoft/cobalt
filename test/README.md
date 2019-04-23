# Resource Deployment Testing in Cobalt

## Summary

This section describes how to build integration and validation tests for your cobalt deployment environments using the terratest modules.

Terratest is a Go library that makes it easier to write automated tests for your infrastructure code. It provides a variety of helper functions and patterns for common infrastructure testing tasks.

In addition, the cobalt test suite allows for better collaboration with embedding into CI/CD tools such as Travis or Azure DevOps Pipelines.

## Prerequisites
- [Docker](https://docs.docker.com/install/) 18.09 or later

## Test Setup Locally

In this example we are using the [`azure-simple`](/infra/templates/azure-simple/readme.md) for a template integration test.
