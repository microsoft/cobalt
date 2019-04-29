variable "name" {
  type        = "string"
  description = "Specifies the human consumable label for this resource."
}

variable "location" {
  type        = "string"
  description = "Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
}

variable "resource_tags" {
  type        = "string"
  description = "Map of tags to apply to taggable resources in this module.  By default the taggable resources are tagged with the name defined above and this map is merged in"
  type        = "map"
  default     = {}
}