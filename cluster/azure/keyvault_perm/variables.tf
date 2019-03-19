variable "resource_group_name" {
    type = "string"
}

variable "service_principal_id" {
    type = "string"
}

variable "service_principal_secret" {
    type = "string"
}

variable "tenant_id" {
    type = "string"
}

variable "subscription_id" {
    type = "string"
}

variable "user_role_assignment_role" {
    description = "The role to give the Azure service principal to access the keyvault"
    type = "string"
    default = "Reader"
}

variable "user_keyvault_key_permissions" {
    description = "Permissions that the Azure cluster has for accessing keys from KeyVault"
    type = "list"
    default = ["create", "delete", "get"]
}

variable "user_keyvault_secret_permissions" {
    description = "Permissions that the Azure cluster has for accessing secrets from KeyVault"
    type = "list"
    default = ["set", "delete", "get"]
}

variable "user_keyvault_certificate_permissions" {
    description = "Permissions that the Azure cluster has for accessing certificates from KeyVault"
    type = "list"
    default = ["create", "delete", "get"]
}

variable "output_directory" {
    type = "string"
    default = "./output"
}

variable "keyvault_name" {
    description = "The name of the keyvault that will be associated with the flex volume."
    type = "string"
}

variable "keyvault_id" {
    description = "The id of the keyvault that will be associated with the flex volume."
    type = "string"
}
