# Purpose/Description

Cobalts customers expect the ability to configure Authentication for their applications. We've chosen to provide this ability by extending both the Service Principal module and the App Service module. This will enable a customer to configure "Easy Auth" on their App Service using an application registration in Azure Active Directory.
Azure App Service provides built-in authentication and authorization support, so you can sign in users and access data by writing minimal or no code in your web app, RESTful API, and mobile back end, and also Azure Functions. This article describes how App Service helps simplify authentication and authorization for your app.

# Component Diagram

![EasyAuthDiagram](https://user-images.githubusercontent.com/10041279/59792761-8544ac80-929a-11e9-89f2-2a3b394f820a.PNG)

### App Service Module - AAD App Inputs

Registering app with AAD tenant gives an application an appID (unique client identifier) as well as enables it to receive tokens.

| Name | Type | Default | Description |
|---|---|---|---|
| `available_to_other_tenants` | bool | `false` | Scopes the web app at the Azure AD tenant level. |
| `app_display_name` | string | - | The name of the web app. |
| `app_homepage` | string | - | The URL to the web app's home page. |
| `reply_urls` | list(string) | - | Redirect URL post sign-in. For web apps, provide the base url of the web app. |

### App Service Module - AuthN Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `resource_group_location` | string | - | The deployment location of resource group container for all the resources |
| `name` | string | - | The name of the web app. |
| `enable_easyauth` | bool | `true` | Whether or not to secure the application with Azure AD. |
| `aad_app_sp` | string | - | If `enable_easyauth` is true, the Azure AD Service Principal of the the web app. |
| `ad_client_id` | string | "" | If `enable_easyauth` is true, Azure AD registration/client id for enabling openIdConnection authentication. |

# Template Outputs

|Name|Type|Description|
|----|----|-----------|
|`application_id`| string | The unique identifier for one of the Azure AD Application instance.|
