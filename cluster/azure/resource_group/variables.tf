variable "resource_group_location" {
    type = "string"
    description = "The name of the target location"
    default = "eastus"
}
variable "env" {
    type = "string",
    description = "The short name of the target env (i.e. dev, staging, or prod)"
    default = "dev"
}
variable "org" {
    type = "string",
    description = "The short name of the organization"
    default = "test"
}
