# Purpose/Description
<!-- 
Who is the user?
What does it do?
When does a users use this?
Why does a user want this?
How does a user use this?
-->

An engineer wants to get a successful resonse back from an appication using Azure AD based Authentication deployed to Cobalt managed infastrcuture. And/or, An engineer wants to get an unauthorized response from the request to verify they are unable to access the resource. This demonstrates that the infastructure is deployed correctly for the application, the application is successfully deployed to the infrastructure, and that authentication is working correctly.

An engineer, who is creating a template, should want to create integration tests that test the deployed infastructure functionality and/or the application deployed. There are two use cases we see this being the case:
  1. Application Infastructure prociding Authentication for a deployed application
  2. A deployed application with authentication.

These tests are provided after the infastructure has been deployed and before releasing code into a new environment. 

The user will make use of the HTTP_GET function that utilizes the existing AUTHORIZOR function to obtain a bearer token.

# Background Information
<!--
Tech used
How do these tech work?
Reference links to these tech
Reference diagrams for tech 
-->
To allow integration tests to authenticate to an application, the OAuth 2.0 Client Credentials Grant Flow is used. This permits a confidential client to use its own credentials instead of impersonating a user, to authenticate when calling another service, web or otherwise.

![image](https://user-images.githubusercontent.com/17349002/61244953-64e10400-a719-11e9-90ce-82d88e29ab81.png)

ref: [Service to service calls using client credentials](https://docs.microsoft.com/en-us/azure/active-directory/develop/v1-oauth2-client-creds-grant-flow)

# Out-of-Scope
<!-- 
When and why would a user not use this?
What are related items that will not be addressed?
-->

  1. POST, DELETE, and other types or requests besided GET are out of scope.
  2. Synthetic tests are out of scope.

# Swimlane Diagram
<!-- 
What is the right diagram?
	Sequence Diagram - When you want to show data/information flow.
	Comonent Diagram - When you want to show how components of a system interact.
	Swimlane Diagram - When you want to show information/data flow between domains and or comonents.
	UML Diagram      - When you want to show how OO class/interface design.
-->
![image](https://user-images.githubusercontent.com/17349002/61076671-c7b95f00-a3ea-11e9-8361-205ed088d0f6.png)

# Inputs
<!-- 
What are the inputs?
What are the input types?
What are the input descriptions?
How are the inputs provided?
-->

All inputs are provied to the functions used by the testing framework by the user. The Service Principle Secret should be stored in Key Vault and access at the time of the function call so that it's not stored in memory anylonger than needed.

| Name | Type | Description |
|------|------|-------------|
| Serivce Principle ID | string | Service Principle ID with Access to Application |
| Serivce Principle Secret | string | Service Principle Secret |
| tenant id | string | ID of the tenant where the Serivce Principle resides |
| url to test | string | HTTP URL of the service to be tested |

# Outputs
<!-- 
What does this return to the program or user? 
How are the outputs surfaced?
-->

The function should output the resonse and response code to the calling function.

| Name | Type | Description |
|------|------|-------------|
| Response Body | JSON, String, Binary, etc | The body of the resonse returned by the service |
| Status Code | integer | The response status code. Examples: 200 401 500 |