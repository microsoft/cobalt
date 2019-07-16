# Purpose/Description

For this design, an engineer building a template would like the ability to test a deployed application with Authentication. Currently the Cobalt test-harness cannot and the http calls to an authenticated service will return a 401 unauthorized. This is help in its self because it does show that authentication has been configured. However, we would like the ability to also test for a 200 Successful status code. This will give the ability for the CI/CD pipeline to test for both negative and positive results during a deployment.

There are two use cases we see an engineer would like to test:
  1. Application Infrastructure providing authentication for a deployed application
  2. A deployed application with authentication.

The infrastructure should be deployed by the CI/CD pipeline, either local or cloud based. Once the infrastructure is deployed the integration test should be run against that infrastructure. The echo server image should be deployed to the app service behind EasyAuth using AAD as the provider. Testing for both a 401 and 200 status codes will allow us to understand that the infrastructure is deployed correctly.

Also, after deploying the application containers to the infrastructure, a 401 and 200 status code will similarly allow us to test if the application has been deployed successfully to the environment. These test should be run in each environment i.e. Dev-Int, Stage, QA, Production, etc...

The user will make use of the HTTP_GET function that utilizes the existing AUTHORIZER function to obtain a bearer token.

# Background Information

To allow integration tests to authenticate to an application, the OAuth 2.0 Client Credentials Grant Flow is used. This permits a confidential client to use its own credentials instead of impersonating a user, to authenticate when calling another service, web or otherwise.

![image](https://user-images.githubusercontent.com/17349002/61244953-64e10400-a719-11e9-90ce-82d88e29ab81.png)

ref: [Service to service calls using client credentials](https://docs.microsoft.com/en-us/azure/active-directory/develop/v1-oauth2-client-creds-grant-flow)

# Out-of-Scope

  1. POST, DELETE, and other types or requests besides GET are out of scope.
  2. Synthetic tests are out of scope.

# Swim lane Diagram

![image](https://user-images.githubusercontent.com/17349002/61076671-c7b95f00-a3ea-11e9-8361-205ed088d0f6.png)

# Inputs

All inputs are provided to the functions used by the testing framework by the user. The Service Principle Secret should be stored in Key Vault and access at the time of the function call so that it's not stored in memory any longer than needed.

| Name | Type | Description |
|------|------|-------------|
| Service Principle ID | string | Service Principle ID with Access to Application |
| Service Principle Secret | string | Service Principle Secret |
| tenant id | string | ID of the tenant where the Service Principle resides |
| url to test | string | HTTP URL of the service to be tested |

# Outputs

The function should output the response and response code to the calling function.

| Name | Type | Description |
|------|------|-------------|
| Response Body | JSON, String, Binary, etc | The body of the response returned by the service |
| Status Code | integer | The response status code. Examples: 200 401 500 |