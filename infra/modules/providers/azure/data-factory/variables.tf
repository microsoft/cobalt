variable "resource_group_name" {
  description = "(The name of the resource group in which to create the Managed Integration Runtime. Changing this forces a new resource to be created."
  type        = string
}

variable "data_factory_name" {
  description = "Specifies the name of the Data Factory the Managed Integration Runtime belongs to. Changing this forces a new resource to be created."
  type        = string
}

variable "data_factory_runtime_name" {
  description = "Specifies the name of the Managed Integration Runtime. Changing this forces a new resource to be created. Must be globally unique."
  type        = string
  default     = ""
}

variable "node_size" {
  description = "The size of the nodes on which the Managed Integration Runtime runs. Valid values are: Standard_D2_v3"
  type        = string
  default     = "Standard_D2_v3"
}

variable "number_of_nodes" {
  description = "Number of nodes for the Managed Integration Runtime. Max is 10. Defaults to 1."
  type        = number
  default     = 1
}

variable "edition" {
  description = "The Managed Integration Runtime edition. Valid values are Standard and Enterprise. Defaults to Standard."
  type        = string
  default     = "Standard"
}

variable "max_parallel_executions_per_node" {
  description = "Defines the maximum parallel executions per node. Defaults to 1. Max is 16."
  type        = number
  default     = 1
}

variable "vnet_integration" {

  type = object({
    vnet_id     = string #ID of the virtual network to which the nodes of the Managed Integration Runtime will be added
    subnet_name = string #Name of the subnet to which the nodes of the Managed Integration Runtime will be added.
  })
}

variable "data_factory_pipeline_name" {
  description = "Specifies the name of the Data Factory Pipeline. Changing this forces a new resource to be created. Must be globally unique."
  type        = string
  default     = ""
}

variable "data_factory_trigger_name" {
  description = "Specifies the name of the Data Factory Schedule Trigger. Changing this forces a new resource to be created. Must be globally unique."
  type        = string
  default     = ""
}

variable "data_factory_trigger_interval" {
  description = "The interval for how often the trigger occurs. This defaults to 1."
  type        = number
  default     = 1
}

variable "data_factory_trigger_frequency" {
  description = "The trigger freqency. Valid values include Minute, Hour, Day, Week, Month. Defaults to Minute."
  type        = string
  default     = "Minute"
}