# Purpose/Description

For this design, an engineer building a template would like the ability to test a deployed application with authentication enabled. Currently the Cobalt test-harness cannot successfully complete http calls to an authenticated service and they will return a 401 unauthorized in the response. This is helpful in its self, because it does show that authentication has been configured. However, we would like the ability to also test for a 200 Successful status code. This will give the ability for the CI/CD pipeline to test for both negative and positive results during a deployment.

There are two use cases we see an engineer would like to test:
  1. Application Infrastructure deployment with  authentication enabled.
  2. A deployed application with authentication enabled.

The infrastructure should be deployed by the CI/CD pipeline, either local or cloud based. Once the infrastructure is deployed the integration test should be run against that infrastructure. The [echo server](https://hub.docker.com/r/msftcse/cobalt-azure-simple) image should be deployed to the app service behind EasyAuth using AAD as the provider. Testing for both a 401 and 200 status codes will allow us to understand that the infrastructure is deployed correctly.

Also, after deploying the application containers to the infrastructure, a 401 and 200 status code will similarly allow us to test that the application has been deployed successfully to the environment. These tests should be run in each environment i.e. Dev-Int, Stage, QA, Production, etc...

The user will make use of the HTTP_GET function that utilizes the existing AUTHORIZER function to obtain a bearer token.

# Background Information

Using the credentials grant flow allows a client to using it's own Service Principle and Secret as a username/password to authenticate to the service that it's calling.

To allow integration tests to authenticate to an application, the OAuth 2.0 Client Credentials Grant Flow is used. This permits a confidential client to use its own credentials instead of impersonating a user, to authenticate when calling another service, web or otherwise.

![image](https://user-images.githubusercontent.com/17349002/61244953-64e10400-a719-11e9-90ce-82d88e29ab81.png)

## Example Request
```
POST /contoso.com/oauth2/token HTTP/1.1
Host: login.microsoftonline.com
Content-Type: application/x-www-form-urlencoded

grant_type=client_credentials&client_id=625bc9f6-3bf6-4b6d-94ba-e97cf07a22de&client_secret=qkDwDJlDfig2IpeuUZYKH1Wb8q1V0ju6sILxQQqhJ+s=&resource=https%3A%2F%2Fservice.contoso.com%2F
```

## Example Response
```
{
"access_token":"eyJhbGciOiJSUzI1NiIsIng1dCI6IjdkRC1nZWNOZ1gxWmY3R0xrT3ZwT0IyZGNWQSIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJodHRwczovL3NlcnZpY2UuY29udG9zby5jb20vIiwiaXNzIjoiaHR0cHM6Ly9zdHMud2luZG93cy5uZXQvN2ZlODE0NDctZGE1Ny00Mzg1LWJlY2ItNmRlNTdmMjE0NzdlLyIsImlhdCI6MTM4ODQ0ODI2NywibmJmIjoxMzg4NDQ4MjY3LCJleHAiOjEzODg0NTIxNjcsInZlciI6IjEuMCIsInRpZCI6IjdmZTgxNDQ3LWRhNTctNDM4NS1iZWNiLTZkZTU3ZjIxNDc3ZSIsIm9pZCI6ImE5OTE5MTYyLTkyMTctNDlkYS1hZTIyLWYxMTM3YzI1Y2RlYSIsInN1YiI6ImE5OTE5MTYyLTkyMTctNDlkYS1hZTIyLWYxMTM3YzI1Y2RlYSIsImlkcCI6Imh0dHBzOi8vc3RzLndpbmRvd3MubmV0LzdmZTgxNDQ3LWRhNTctNDM4NS1iZWNiLTZkZTU3ZjIxNDc3ZS8iLCJhcHBpZCI6ImQxN2QxNWJjLWM1NzYtNDFlNS05MjdmLWRiNWYzMGRkNThmMSIsImFwcGlkYWNyIjoiMSJ9.aqtfJ7G37CpKV901Vm9sGiQhde0WMg6luYJR4wuNR2ffaQsVPPpKirM5rbc6o5CmW1OtmaAIdwDcL6i9ZT9ooIIicSRrjCYMYWHX08ip-tj-uWUihGztI02xKdWiycItpWiHxapQm0a8Ti1CWRjJghORC1B1-fah_yWx6Cjuf4QE8xJcu-ZHX0pVZNPX22PHYV5Km-vPTq2HtIqdboKyZy3Y4y3geOrRIFElZYoqjqSv5q9Jgtj5ERsNQIjefpyxW3EwPtFqMcDm4ebiAEpoEWRN4QYOMxnC9OUBeG9oLA0lTfmhgHLAtvJogJcYFzwngTsVo6HznsvPWy7UP3MINA",
"token_type":"Bearer",
"expires_in":"3599",
"expires_on":"1388452167",
"resource":"https://service.contoso.com/"
}
```

ref: [Service to service calls using client credentials](https://docs.microsoft.com/en-us/azure/active-directory/develop/v1-oauth2-client-creds-grant-flow)

# Out-of-Scope

  1. POST, DELETE, and other types or requests besides GET are out of scope.
  2. Synthetic tests are out of scope.

# Swim lane Diagram

![image](https://user-images.githubusercontent.com/17349002/61076671-c7b95f00-a3ea-11e9-8361-205ed088d0f6.png)

# Authorizer Function

Currently there is a working function that provides the functionality needed to obtain a valid bearer token. This will be used as the "Authorizer" function referenced in the swim lane diagram above.

```go
// ServicePrincipalAuthorizer - Configures a service principal authorizer that can be used to create bearer tokens
func ServicePrincipalAuthorizer(clientID string, clientSecret string, resource string) (autorest.Authorizer, error) {
	oauthConfig, err := adal.NewOAuthConfig(az.PublicCloud.ActiveDirectoryEndpoint, os.Getenv("ARM_TENANT_ID"))
	if err != nil {
		return nil, err
	}

	token, err := adal.NewServicePrincipalToken(*oauthConfig, clientID, clientSecret, resource)
	if err != nil {
		return nil, err
	}

	return autorest.NewBearerAuthorizer(token), nil
}
```

ref: [authorizer.go: Lines 19 - 32](https://github.com/microsoft/cobalt/blob/35e73daea4231bd8ded378fc3d386ac06f7e39d7/test-harness/terratest-extensions/modules/azure/authorizer.go#L19-L32)

# Inputs

All inputs are provided to the functions used by the [testing framework integrated into Cobalt](https://github.com/microsoft/cobalt/blob/master/test-harness/README.md) by the user. The Service Principle Secret should be stored in Key Vault and accessed only at the time of the function call so that it's not stored in memory any longer than needed.

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