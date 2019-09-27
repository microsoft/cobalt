// ---- General Configuration ----

variable "name" {
  description = "An identifier used to construct the names of all resources in this template."
  type        = string
}

variable "randomization_level" {
  description = "Number of additional random characters to include in resource names to insulate against unexpected resource name collisions."
  type        = number
  default     = 8
}

variable "resource_group_location" {
  description = "The Azure region where all resources in this template should be created."
  type        = string
}



// ---- App Service Configuration ----

variable "application_type" {
  description = "Type of the App Insights Application.  Valid values are ios for iOS, java for Java web, MobileCenter for App Center, Node.JS for Node.js, other for General, phone for Windows Phone, store for Windows Store and web for ASP.NET."
  default     = "Web"
}

variable "acr_build_git_source_url" {
  description = "The URL to a git repository (e.g., 'https://github.com/Azure-Samples/acr-build-helloworld-node.git') containing the docker build manifests."
  type        = string
}

variable "acr_build_docker_file" {
  description = "The relative path of the the docker file to the source code root folder. Default to 'Dockerfile'."
  type        = string
  default     = "Dockerfile"
}

variable "deployment_targets" {
  description = "Metadata about apps to deploy, such as image metadata."
  type = list(object({
    app_name                 = string
    image_name               = string
    image_release_tag_prefix = string
  }))
}

variable "azure_container_resource_group" {
  description = "The resource group name for the azure container registry instance."
  type        = string
  default     = ""
}

variable "azure_container_resource_name" {
  description = "The resource name for the azure container registry instance."
  type        = string
  default     = ""
}

variable "azure_container_tags" {
  description = "A mapping of tags to assign to the resource.."
  type        = map(string)
  default     = {}
}

variable "subnet_service_endpoints" {
  description = "The list of service endpoints that will be given to each subnet"
  type        = list(string)
  default     = ["Microsoft.Web"]
}

variable "address_space" {
  description = "The address space that is used by the virtual network."
  default     = "10.0.0.0/16"
}

variable "subnet_names" {
  description = "A list of public subnets inside the vNet."
  default     = ["app-gateway"]
}

variable "subnet_prefixes" {
  description = "The address prefix to use for the subnet."
  default     = ["10.0.1.0/24"]
}


// ---- Monitoring Service Configuration ----

variable "action_group_name" {
  description = "The name of the action group."
  type        = string
  default     = "Simple Default Action Group"
}

variable "action_group_email_receiver" {
  description = "The e-mail receiver for an alert rule resource."
  type        = string
  default     = ""
}

variable "metric_alert_name" {
  description = "The display name of a group of metric alert criteria."
  type        = string
  default     = "Simple Default Metric Alerts"
}

variable "metric_alert_frequency" {
  description = "The frequency with which the metric alert checks if the conditions are met."
  type        = string
  default     = "PT1M"
}

variable "metric_alert_period" {
  description = "The look back window over which metric values are checked. Value must be greater than 'frequency'."
  type        = string
  default     = "PT5M"
}

variable "metric_alert_criteria_namespace" {
  description = "A monitored resource namespace with configurable metric alert criteria."
  type        = string
  default     = "Microsoft.Web/serverfarms"
}

variable "metric_alert_criteria_name" {
  description = "A predefined Azure resource alert monitoring rule name."
  type        = string
  default     = "CpuPercentage"
}

variable "metric_alert_criteria_aggregation" {
  description = "The calculation used for building metric alert criteria."
  type        = string
  default     = "Average"
}

variable "metric_alert_criteria_operator" {
  description = "A logical operator used for building metric alert criteria."
  type        = string
  default     = "GreaterThan"
}

variable "metric_alert_criteria_threshold" {
  description = "The criteria threshold value that activates the metric alert."
  type        = number
  default     = 50
}

variable "monitoring_dimension_values" {
  description = "Dimensions used to determine service plan scaling."
  type        = list(string)
  default     = ["*"]
}
