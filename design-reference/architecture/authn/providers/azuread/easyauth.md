# Purpose/Description

This design addresses the ability for a user of a web application hosted in Azure App Services to login and use the web application as an authenticated user. We are following best practices we've both observed in practice and provided in Microsoft's documentation.

Authentication is provided by Azure Active Directory. This is configured using "EasyAuth" DLL. The authentication and authorization DLL runs in the same sandbox as your application code. When it's enabled, every incoming HTTP request passes through it before being handled by your application code.

![image](https://user-images.githubusercontent.com/17349002/60189171-23ce9180-97f6-11e9-8b4d-20235832180c.png)

Cobalt customers expect the ability to configure Authentication for their applications. We've chosen to provide this ability by extending both the Service Principal module and the App Service module. This will enable a customer to configure "Easy Auth" on their App Service using an application registration in Azure Active Directory.

Azure App Service provides built-in authentication and authorization support, so you can sign in users and access data by writing minimal or no code in your web app, RESTful API, and mobile back end, and also Azure Functions. This article describes how App Service helps simplify authentication and authorization for your app.

# OAuth2 Implicit Grant Flow

We expect the customers using this configuration to follow the OAuth2 Implicit Grant Flow specified in section [1.3.2 of RFC6749](https://tools.ietf.org/html/rfc6749#section-1.3.2).

With the Microsoft identity platform endpoint, you can sign users into your single-page apps with both personal and work or school accounts from Microsoft. For these applications (AngularJS, Ember.js, React.js, and so on), Microsoft identity platform supports the OAuth 2.0 Implicit Grant flow. The implicit flow is described in the OAuth 2.0 Specification. Its primary benefit is that it allows the app to get tokens from Microsoft identity platform without performing a backend server credential exchange. This allows the app to sign in the user, maintain session, and get tokens to other web APIs all within the client JavaScript code.

![image](https://user-images.githubusercontent.com/17349002/60187842-eb2db880-97f3-11e9-947d-29e98aca1881.png)

> Reference documentation:
> [Microsoft identity platform and Implicit grant flow](https://docs.microsoft.com/en-us/azure/active-directory/develop/v2-oauth2-implicit-grant-flow)

# Out-of-Scope

We are currently not including the following items in the creating of this module.

  1. Native Application Types
  2. User/Role Creating
  3. User/Role Assignment

# Component Diagram

![image](https://user-images.githubusercontent.com/17349002/60193845-f685e180-97fd-11e9-8474-d1056a7ccaa8.png)

# Service Principle Module Inputs

We plan to extend the current Service Principle Module to support the following inputs as configuration items for the `azuread_application` resource.

> This inputs are in addition to the existing inputs the module already provides

| Name | Type | Default | Description |
|---|---|---|---|
| `available_to_other_tenants` | bool | `false` | Scopes the web app at the Azure AD tenant level. |
| `reply_urls` | list(string) | - | Sign-on url for web based apps. Redirect URL for non-web based apps. For web apps, provide the base url of the web app. By default, Sign-on url will also be the default url after being succesfully logged in. |

# Service Principle Module Outputs

The service principle module already outputs this value. We are pointing this out because it will be used as an input argument for the App Service module to configure EasyAuth's `active_directory` > `ad_client_id` parameter.

Expected uses for this value:
  1. Input into the App Service module to configure AuthN.
  2. Input into the App Service module to be passed into container using `app_settings`.

|Name|Type|Description|
|----|----|-----------|
|`application_id`| string | The unique identifier for the Azure AD Application instance.|

# App Service Module Inputs

We plan to extend the current App Service Module to support the following inputs as configuration items for the `azurerm_app_service` resource.

> These inputs are in addition to the existing inputs the module already provides

| Name | Type | Default | Description |
|---|---|---|---|
| `ad_client_id`       | string | "" | If `ad_client_id` is not empty, an app service is opted into Azure AD registration/client id for enabling openIdConnection authentication. |
| `external_tenant_id` | string | "" | If `external_tenant_id` is not empty, Azure AD registration/client id lives in a different tenant. |

# App Service Module Outputs

There are no new requirements for this module to output specific values due to these changes.
