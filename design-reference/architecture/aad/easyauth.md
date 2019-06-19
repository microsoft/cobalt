# Purpose/Description

    AuthN
    
    We’re using App Services Easy Auth for AuthN.

# Input

    1. AAD Application
        1. Single Tenant or Multi-Tenant
        2. Redirect URL
        3. Application Type (Web/Public Client)
        4. App Secret (????)(Is this proveded or generated)
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
