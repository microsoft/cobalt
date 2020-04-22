variable "command" {
  description = "A command to run"
  type        = string
}

variable "environment" {
  description = "A key-value map of environment variables to run with the command"
  type        = map(string)
  default     = {}
}
