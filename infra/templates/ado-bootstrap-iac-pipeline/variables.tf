variable "environments" {
  description = "Tiers for deployments"
  type = list(object({
    environment = string,
    az_sub_id   = string
  }))
}

variable "project_name" {
}
