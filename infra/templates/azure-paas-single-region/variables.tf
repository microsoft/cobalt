# Resource Group
variable "resource_group_location" {
  description = "The deployment location of resource group container all the resources"
  type        = string
}

variable "application_type" {
  description = "Type of the App Insights Application.  Valid values are ios for iOS, java for Java web, MobileCenter for App Center, Node.JS for Node.js, other for General, phone for Windows Phone, store for Windows Store and web for ASP.NET."
  default     = "Web"
}

variable "name" {
  description = "The name of the deployment.  This will be used across the resource created in this solution"
  type        = string
}

variable "acr_build_git_source_url" {
  description = "The URL to a git repository (e.g., 'https://github.com/Azure-Samples/acr-build-helloworld-node.git') containing the docker build manifests."
  type        = string
}

variable "app_service_name" {
  description = "The name key value pair where the key is the name assigned to the app service and value is the source container"
  type        = map(string)
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

# Monitoring Service
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

variable "scaling_values" {
  description = "Targets app instances made available from app service plan scaling options."
  type        = list(string)
  default     = ["*"]
}

variable "acr_build_docker_file" {
  description = "The relative path of the the docker file to the source code root folder. Default to 'Dockerfile'."
  type        = string
  default     = "Dockerfile"
}

