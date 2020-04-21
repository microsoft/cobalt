variable "environments" {
  description = "The environments and Az Subcriptions that IaC CI/CD will provision"
  type = list(object({
    environment = string,
    az_sub_id   = string
  }))
}

variable "project_name" {
  description = "The name of an existing proejct that will be provisioned to run the IaC CI/CD pipelines"
}
