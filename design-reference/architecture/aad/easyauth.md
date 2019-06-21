# Purpose/Description

    AuthN
    
    We’re using App Services Easy Auth for AuthN.

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

### Azure AD Inputs

| name | type | default | description |
|---|---|---|---|
| `app_display_name` | string | - | The name of the web app. |
| `app_homepage` | string | - | The name of the web app. |
| `identifier_uris` | list(string) | `[]` | A custom list of URLs belonging to the web app within a single tenant. |
| `reply_urls` | string | - | The name of the web app. |
| `oauth2_allow_implicit_flow` | bool | true | Does this Azure AD Application allow OAuth2.0 implicit flow tokens? |
| `group_membership_claims` | string | SecurityGroup | Configures the groups claim issued in a user or OAuth 2.0 access token that the app expects |
| `resource_app_ids` | string | - | The unique identifiers for the resource that the application requires access to. |
| `resource_access_ids` | string | - | The name of the web app. |
| `resource_access_types` | string | - | The name of the web app. |

### App Service Module Inputs

| name | type | default | description |
|---|---|---|---|
| `resource_group_location` | string | - | The deployment location of resource group container for all the resources |
| `name` | string | - | The name of the web app. |
| `enable_auth` | bool | `true` | Whether or not to secure the application with active directory. |
| `ad_client_id` | string | "" | Azure AD registration/client id for enabling openIdConnection authentication. |
| `ad_client_secret` | string | "" | If no secret is provided, implicit flow will be used. |
| `ad_allowed_audiences` | list(string) | `[app.uri]` |  A list of URLs belonging to the web app that can authenticate against AAD and receive Json Web Tokens. |
| `auth_additional_login_params` | list(string) | `[resource=https://graph.microsoft.com]` | Login parameters to send to the OpenID Backend API Connect authorization endpoint when a user logs in if `enable_auth` is true. Each parameter must be in the form "key=value". |
| `auth_issuer` | string | `https://sts.windows.net/%7Btenant-guid%7D/` | The OpenID Connect Issuer URI that represents the entity which issues access tokens for this application. When using Azure Active Directory, this value is the URI of the directory tenant. |
| `auth_default_provider` | string | `AzureActiveDirectory` | The name of the provider being used for authentication. |
| `auth_unauthenticated_client_action` | string | `RedirectToLoginPage` | Settings instructing web client to redirect to login page upon failed authentication attempts. |
| `token_store_enabled` | bool | `true` |  If enabled the module will durably store platform-specific security tokens that are obtained during login flows. |
