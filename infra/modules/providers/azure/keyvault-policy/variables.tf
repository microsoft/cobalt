variable "vault_id" {
  description = "Specifies the name of the Key Vault resource."
  type = "string"
}

variable "tenant_id" {
  description = "The Azure Active Directory tenant ID that should be used for authenticating requests to the key vault. Changing this forces a new resource to be created."
  type = "string"
}

variable "instance_count" {
  description = "the number of access policies that we need to create. Terraform requires the resource instance count to be known during the plan creation step. This will be removed once we upgrade to TF version 12"
  type = "string"
}

variable "object_ids" {
  description = "The object IDs of a user, service principal or security group in the Azure Active Directory tenant for the vault. The object ID must be unique for the list of access policies. Changing this forces a new resource to be created."
  type = "list"
}

variable "key_permissions" {
  description = "List of key permissions, must be one or more from the following: backup, create, decrypt, delete, encrypt, get, import, list, purge, recover, restore, sign, unwrapKey, update, verify and wrapKey"
  type    = "list"
  default = ["create", "delete", "get", "list"]
}

variable "secret_permissions" {
  type    = "list"
  description = "List of secret permissions, must be one or more from the following: backup, delete, get, list, purge, recover, restore and set."
  default = ["delete", "get", "set", "list"]
}

variable "certificate_permissions" {
  type    = "list"
  description = "List of storage permissions, must be one or more from the following: backup, delete, deletesas, get, getsas, list, listsas, purge, recover, regeneratekey, restore, set, setsas and update."
  default = ["create", "delete", "get", "list"]
}
