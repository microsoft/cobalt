variable "name" {
  type        = "string"
  description = "Specifies the human consumable label for this resource."
}

variable "location" {
  type        = "string"
  description = "Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
}