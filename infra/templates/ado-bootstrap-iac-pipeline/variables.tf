variable "environments" {
  description = "Tiers for deployments"
  type = list(object({
    environment     = string,
    az_sub_id = string
  }))
  default = [
    {
      environment     = "devint",
      az_sub_id = "3828bc08-0fef-4aa5-acc9-8c6bf05293be"
      }, {
      environment     = "qa",
      az_sub_id = "3828bc08-0fef-4aa5-acc9-8c6bf05293be"
      }, {
      environment     = "prod",
      az_sub_id = "3828bc08-0fef-4aa5-acc9-8c6bf05293be"
    }
  ]
}
