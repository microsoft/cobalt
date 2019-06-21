# Purpose/Description

Cobalts customers expect the ability to configure Authentication for their applications. We've chosen to provide this ability by extending both the Service Principal module and the App Service module. This will enable a customer to configure "Easy Auth" on their App Service using an application registration in Azure Active Directory.
Azure App Service provides built-in authentication and authorization support, so you can sign in users and access data by writing minimal or no code in your web app, RESTful API, and mobile back end, and also Azure Functions. This article describes how App Service helps simplify authentication and authorization for your app.

# Input

    1. AAD Application
        1. Single Tenant or Multi-Tenant
        2. Redirect URL
        3. Application Type (Web/Public Client)
        4. App Secret (????)(Is this provided or generated)
    2. AAD Application SP
    3. App Service
        1. auth_settings
            1. enabled (bool)
            2. active_directory
                1. client_id (application_id)
                2. client_secret (????)
                3. allowed_audiences

# Component Diagram

![EasyAuthDiagram](https://user-images.githubusercontent.com/10041279/59792761-8544ac80-929a-11e9-89f2-2a3b394f820a.PNG)

# Output

    1. AAD Application
        1. App ID (used by app code)
        2. Client secret (???)
            1. Keyvault

## Module Inputs

### App Service Module - AAD App Inputs

Registering app with AAD tenant gives an application an appID (unique client identifier) as well as enables it to receive tokens.

| name | type | default | description |
|---|---|---|---|
| `available_to_other_tenants` | bool | `false` | Scopes the web app at the Azure AD tenant level. |
| `app_display_name` | string | - | The name of the web app. |
| `app_homepage` | string | - | The URL to the web app's home page. |
| `reply_urls` | list(string) | - | Redirect URL post sign-in. For web apps, provide the base url of the web app. |
| `resource_app_id` | string | - | The appId of a resource that this application requires access to. |
| `resource_access_id` | string | - | The property id representing an OAuth2Permission or AppRole instance of the application that this application requires access to. |
| `resource_access_type` | string | - | The type of the id property. Possible values are Scope or Role. |
| `oauth2_allow_implicit_flow` | bool | `true` | Allows authentication without secrets using the Oauth2 implicit flow? |
| `group_membership_claims` | string | `SecurityGroup` | Configures the groups claim issued in a user or OAuth 2.0 access token that the app expects?????? |

### App Service Module - AuthN Inputs

| name | type | default | description |
|---|---|---|---|
| `resource_group_location` | string | - | The deployment location of resource group container for all the resources |
| `name` | string | - | The name of the web app. |
| `enable_easyauth` | bool | `true` | Whether or not to secure the application with Azure AD. |
| `aad_app_sp` | string | - | If `enable_easyauth` is true, the Azure AD Service Principal of the the web app. |
| `ad_client_id` | string | "" | If `enable_easyauth` is true, Azure AD registration/client id for enabling openIdConnection authentication. |
| `ad_client_secret` | string | "" | If no secret is provided, implicit flow will be used. |
| `ad_allowed_audiences` | list(string) | `[]` |  If `enable_easyauth` is true, a list of URLs belonging to the web app that also can authenticate against Azure AD and receive Json Web Tokens. |
| `auth_additional_login_params` | list(string) | `[resource=https://graph.microsoft.com]` | If `enable_easyauth` is true, login parameters to send to the OpenID Backend API Connect authorization endpoint when a user logs in. Each parameter must be in the form "key=value". |
| `auth_issuer` | string | `https://sts.windows.net/%7Btenant-guid%7D/` | If `enable_easyauth` is true, the OpenID Connect Issuer URI that represents the entity which issues access tokens for this application. When using Azure AD, this value is the URI of the directory tenant. |
| `auth_default_provider` | string | `AzureActiveDirectory` | If `enable_easyauth` is true, the name of the provider being used for authentication. |
| `auth_unauthenticated_client_action` | string | `RedirectToLoginPage` | Settings instructing web app to redirect to login page upon failed authentication attempts. |
| `token_store_enabled` | bool | `true` |  If enabled the module will durably store platform-specific security tokens that are obtained from Azure AD during login flows. |

# Template Outputs

|Name|Type|Description|
|----|----|-----------|
|`application_id`| string | The unique identifier for one of the Azure AD Application instance.|
